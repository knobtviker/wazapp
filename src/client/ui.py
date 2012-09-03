'''
Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>

This file is part of Wazapp, an IM application for Meego Harmattan platform that
allows communication with Whatsapp users

Wazapp is free software: you can redistribute it and/or modify it under the 
terms of the GNU General Public License as published by the Free Software 
Foundation, either version 2 of the License, or (at your option) any later 
version.

Wazapp is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with 
Wazapp. If not, see http://www.gnu.org/licenses/.
'''
import sys
from PySide import QtCore
from PySide.QtCore import *
from PySide.QtGui import *
from PySide.QtDeclarative import QDeclarativeView,QDeclarativeProperty
from QtMobility.Messaging import *
from contacts import WAContacts
from status import WAChangeStatus
from waxmpp import WAXMPP
from utilities import Utilities
#from registration import Registration
from contacts import ContactsSyncer
from messagestore import MessageStore
from threading import Timer
from waservice import WAService
import dbus
from wadebug import UIDebug
import os, shutil

class WAUI(QDeclarativeView):
	quit = QtCore.Signal()
	
	def __init__(self):
		
		_d = UIDebug();
		self._d = _d.d;
	
		
		super(WAUI,self).__init__();
		url = QUrl('/opt/waxmppplugin/bin/wazapp/UI/main.qml')


		
		self.rootContext().setContextProperty("waversion", Utilities.waversion);
		self.setSource(url);
		self.focus = False
		self.whatsapp = None
		self.idleTimeout = None
		
	
	def preQuit(self):
		self._d("pre quit")
		del self.whatsapp
		del self.c
		self.quit.emit()
		
	def initConnections(self,store):
		self.store = store;
		#self.setOrientation(QmlApplicationViewer.ScreenOrientationLockPortrait);
		#self.rootObject().sendRegRequest.connect(self.sendRegRequest);
		self.c = WAContacts(self.store);
		self.c.contactsRefreshed.connect(self.populateContacts);
		self.c.contactsRefreshed.connect(self.rootObject().onRefreshSuccess);
		self.c.contactsRefreshFailed.connect(self.rootObject().onRefreshFail);
		self.c.contactsSyncStatusChanged.connect(self.rootObject().onContactsSyncStatusChanged);
		self.c.contactPictureUpdated.connect(self.rootObject().onContactPictureUpdated);
		#self.c.contactUpdated.connect(self.rootObject().onContactUpdated);
		#self.c.contactAdded.connect(self.onContactAdded);
		self.rootObject().refreshContacts.connect(self.c.resync)
		self.rootObject().sendSMS.connect(self.sendSMS)
		self.rootObject().makeCall.connect(self.makeCall)
		self.rootObject().sendVCard.connect(self.sendVCard)
		self.rootObject().consoleDebug.connect(self.consoleDebug)
		self.rootObject().setLanguage.connect(self.setLanguage)
		
				
		#Changed by Tarek: connected directly to QContactManager living inside contacts manager
		#self.c.manager.manager.contactsChanged.connect(self.rootObject().onContactsChanged);
		#self.c.manager.manager.contactsAdded.connect(self.rootObject().onContactsChanged);
		#self.c.manager.manager.contactsRemoved.connect(self.rootObject().onContactsChanged);


		
		#self.rootObject().quit.connect(self.quit)
		
		self.messageStore = MessageStore(self.store);
		self.messageStore.messagesReady.connect(self.rootObject().messagesReady)
		self.messageStore.conversationReady.connect(self.rootObject().conversationReady)
		self.rootObject().loadMessages.connect(self.messageStore.loadMessages);
		
		
		self.rootObject().deleteConversation.connect(self.messageStore.deleteConversation)
		self.rootObject().deleteMessage.connect(self.messageStore.deleteMessage)
		self.rootObject().conversationOpened.connect(self.messageStore.onConversationOpened)
		self.rootObject().removeSingleContact.connect(self.messageStore.removeSingleContact)
		self.dbusService = WAService(self);
		
	
	def focusChanged(self,old,new):
		if new is None:
			self.onUnfocus();
		else:
			self.onFocus();
	
	def onUnfocus(self):
		self._d("FOCUS OUT")
		self.focus = False
		self.rootObject().appFocusChanged(False);
		self.idleTimeout = Timer(5,self.whatsapp.eventHandler.onUnavailable)
		self.idleTimeout.start()
		self.whatsapp.eventHandler.onUnfocus();
		
	
	def onFocus(self):
		self.focus = True
		self.rootObject().appFocusChanged(True);
		if self.idleTimeout is not None:
			self.idleTimeout.cancel()
		
		self.whatsapp.eventHandler.onFocus();
		self.whatsapp.eventHandler.onAvailable();
	
	def closeEvent(self,e):
		self._d("HIDING")
		e.ignore();
		self.whatsapp.eventHandler.onUnfocus();
		
		
		self.hide();
		
		#self.showFullScreen();
	
	def forceRegistration(self):
		''' '''
		self._d("NO VALID ACCOUNT")
		exit();
		self.rootObject().forceRegistration(Utilities.getCountryCode());
		
	def sendRegRequest(self,number,cc):
		
		
		self.reg.do_register(number,cc);
		#reg =  ContactsSyncer();
		#reg.start();
		#reg.done.connect(self.blabla);

		#reg.reg_success.connect(self.rootObject().regSuccess);
		#reg.reg_fail.connect(self.rootObject().regFail);
		
		#reg.start();
		
	def setLanguage(self,lang):
		if os.path.isfile("/home/user/.wazapp/language.qm"):
			os.remove("/home/user/.wazapp/language.qm")
		shutil.copyfile("/opt/waxmppplugin/bin/wazapp/i18n/" + lang + ".qm", "/home/user/.wazapp/language.qm")


	def consoleDebug(self,text):
		self._d(text);


	def setMyAccount(self,account):
		self.rootObject().setMyAccount(account)
		self.account = account

	def sendSMS(self, num):
		print "SENDING SMS TO " + num
		m = QMessage()
		m.setType(QMessage.Sms)
		a = QMessageAddress(QMessageAddress.Phone, num)
		m.setTo(a)
		m.setBody("")
		s = QMessageService()
		s.compose(m)


	def makeCall(self, num):
		print "CALLING TO " + num
		bus = dbus.SystemBus()
		csd_call = dbus.Interface(bus.get_object('com.nokia.csd', '/com/nokia/csd/call'), 'com.nokia.csd.Call')
		csd_call.CreateWith(str(num), dbus.UInt32(0))
	
	def sendVCard(self,jid,name):
		self.c.exportContact(jid,name);
	
		
	def updateContact(self, jid):
		self._d("POPULATE SINGLE");
		self.c.updateContact(jid);
	
	def updatePushName(self, jid, push):
		#self.c.updateContactPushName(jid,push);
		self._d("UPDATING CONTACTS");
		contacts = self.c.getContacts();
		self.rootObject().updateContactsData(contacts);
		self.rootObject().updatePushName.emit(jid,push);
		

	def populateContacts(self, mode, status=""):
		#syncer = ContactsSyncer(self.store);
		
		#self.c.refreshing.connect(syncer.onRefreshing);
		#syncer.done.connect(c.updateContacts);
		if (mode == "STATUS"):
			self._d("UPDATE CONTACT STATUS");
			self.rootObject().updateContactStatus(status)

		else:
			self._d("POPULATE CONTACTS");
			contacts = self.c.getContacts();
			self.rootObject().pushContacts(contacts);

		#if self.whatsapp is not None:
		#	self.whatsapp.eventHandler.networkDisconnected()

		
	def populateConversations(self):
		self.messageStore.loadConversations()
		

	def populatePhoneContacts(self):
		self._d("POPULATE PHONE CONTACTS");
		contacts = self.c.getPhoneContacts();
		self.rootObject().pushPhoneContacts(contacts);

	
	def login(self):
		self.whatsapp.start();
	
	def showUI(self,jid):
		self._d("SHOULD SHOW")
		self.showFullScreen();
		self.rootObject().openConversation(jid)
		
	def getActiveConversation(self):
		
		if not self.focus:
			return 0
		
		self._d("GETTING ACTIVE CONV")
		
		activeConvJId = QDeclarativeProperty(self.rootObject(),"activeConvJId").read();
		
		#self.rootContext().contextProperty("activeConvJId");
		self._d("DONE - " + str(activeConvJId))
		self._d(activeConvJId)
		
		return activeConvJId
		
	
	def initConnection(self):
		
		password = self.store.account.password;
		usePushName = self.store.account.pushName
		resource = "Symbian-2.8.4-31110";
		chatUserID = self.store.account.username;
		domain ='s.whatsapp.net'
		
		
		
		whatsapp = WAXMPP(domain,resource,chatUserID,usePushName,password);
		
		WAXMPP.message_store = self.messageStore;
	
		whatsapp.setReceiptAckCapable(True);
		whatsapp.setContactsManager(self.c);
		
		whatsapp.eventHandler.connected.connect(self.rootObject().onConnected);
		whatsapp.eventHandler.typing.connect(self.rootObject().onTyping)
		whatsapp.eventHandler.paused.connect(self.rootObject().onPaused)
		whatsapp.eventHandler.showUI.connect(self.showUI)
		whatsapp.eventHandler.messageSent.connect(self.rootObject().onMessageSent);
		whatsapp.eventHandler.messageDelivered.connect(self.rootObject().onMessageDelivered);
		whatsapp.eventHandler.connecting.connect(self.rootObject().onConnecting);
		whatsapp.eventHandler.loginFailed.connect(self.rootObject().onLoginFailed);
		whatsapp.eventHandler.sleeping.connect(self.rootObject().onSleeping);
		whatsapp.eventHandler.disconnected.connect(self.rootObject().onDisconnected);
		whatsapp.eventHandler.available.connect(self.rootObject().onAvailable);
		whatsapp.eventHandler.unavailable.connect(self.rootObject().onUnavailable);
		whatsapp.eventHandler.lastSeenUpdated.connect(self.rootObject().onLastSeenUpdated);
		whatsapp.eventHandler.updateAvailable.connect(self.rootObject().onUpdateAvailable)
		
		whatsapp.eventHandler.groupInfoUpdated.connect(self.rootObject().onGroupInfoUpdated);
		whatsapp.eventHandler.groupCreated.connect(self.rootObject().onGroupCreated);
		whatsapp.eventHandler.addedParticipants.connect(self.rootObject().onAddedParticipants);
		whatsapp.eventHandler.removedParticipants.connect(self.rootObject().onRemovedParticipants);
		whatsapp.eventHandler.groupParticipants.connect(self.rootObject().onGroupParticipants);
		whatsapp.eventHandler.groupEnded.connect(self.rootObject().onGroupEnded);
		whatsapp.eventHandler.groupSubjectChanged.connect(self.rootObject().onGroupSubjectChanged);

		whatsapp.eventHandler.profilePictureUpdated.connect(self.updateContact);

		whatsapp.eventHandler.setPushName.connect(self.updatePushName);
		#whatsapp.eventHandler.setPushName.connect(self.rootObject().updatePushName);
		#whatsapp.eventHandler.profilePictureUpdated.connect(self.rootObject().onPictureUpdated);

		whatsapp.eventHandler.mediaTransferSuccess.connect(self.rootObject().onMediaTransferSuccess);
		whatsapp.eventHandler.mediaTransferError.connect(self.rootObject().onMediaTransferError);
		whatsapp.eventHandler.mediaTransferProgressUpdated.connect(self.rootObject().onMediaTransferProgressUpdated)
		
		whatsapp.eventHandler.doQuit.connect(self.preQuit);
		
		whatsapp.eventHandler.notifier.ui = self
		
		
		#whatsapp.eventHandler.new_message.connect(self.rootObject().newMessage)
		self.rootObject().sendMessage.connect(whatsapp.eventHandler.sendMessage)
		self.rootObject().sendTyping.connect(whatsapp.eventHandler.sendTyping)
		self.rootObject().sendPaused.connect(whatsapp.eventHandler.sendPaused);
		self.rootObject().conversationActive.connect(whatsapp.eventHandler.getLastOnline);
		self.rootObject().conversationActive.connect(whatsapp.eventHandler.conversationOpened);
		self.rootObject().quit.connect(whatsapp.eventHandler.quit)
		self.rootObject().fetchMedia.connect(whatsapp.eventHandler.fetchMedia)
		self.rootObject().fetchGroupMedia.connect(whatsapp.eventHandler.fetchGroupMedia)
		self.rootObject().uploadMedia.connect(whatsapp.eventHandler.uploadMedia)
		self.rootObject().uploadGroupMedia.connect(whatsapp.eventHandler.uploadGroupMedia)
		self.rootObject().getGroupInfo.connect(whatsapp.eventHandler.getGroupInfo)
		self.rootObject().createGroupChat.connect(whatsapp.eventHandler.createGroupChat)
		self.rootObject().addParticipants.connect(whatsapp.eventHandler.addParticipants)
		self.rootObject().removeParticipants.connect(whatsapp.eventHandler.removeParticipants)
		self.rootObject().getGroupParticipants.connect(whatsapp.eventHandler.getGroupParticipants)
		self.rootObject().endGroupChat.connect(whatsapp.eventHandler.endGroupChat)
		self.rootObject().setGroupSubject.connect(whatsapp.eventHandler.setGroupSubject)
		self.rootObject().getPictureIds.connect(whatsapp.eventHandler.getPictureIds)
		self.rootObject().getPicture.connect(whatsapp.eventHandler.getPicture)
		self.rootObject().setPicture.connect(whatsapp.eventHandler.setPicture)
		self.rootObject().sendMediaImageFile.connect(whatsapp.eventHandler.sendMediaImageFile)
		self.rootObject().sendMediaVideoFile.connect(whatsapp.eventHandler.sendMediaVideoFile)
		self.rootObject().sendMediaAudioFile.connect(whatsapp.eventHandler.sendMediaAudioFile)
		self.rootObject().sendMediaMessage.connect(whatsapp.eventHandler.sendMediaMessage)
		self.rootObject().sendLocation.connect(whatsapp.eventHandler.sendLocation)
		#self.rootObject().sendVCard.connect(whatsapp.eventHandler.sendVCard)
		self.c.contactExported.connect(whatsapp.eventHandler.sendVCard)

		self.rootObject().setBlockedContacts.connect(whatsapp.eventHandler.setBlockedContacts)
		self.rootObject().setResizeImages.connect(whatsapp.eventHandler.setResizeImages)

		#self.reg = Registration();
		self.whatsapp = whatsapp;
		
		#change whatsapp status
		self.cs = WAChangeStatus(self.store);
		self.rootObject().changeStatus.connect(self.cs.sync)

		
		#print "el acks:"
		#print whatsapp.supports_receipt_acks
		
		#self.whatsapp.start();
		
		
		

		

