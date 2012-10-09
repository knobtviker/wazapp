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
from mnotification import MNotificationManager,MNotification
from PySide.QtGui import QSound
from PySide.QtCore import QUrl, QCoreApplication
from QtMobility.Feedback import QFeedbackHapticsEffect #QFeedbackEffect
from QtMobility.SystemInfo import QSystemDeviceInfo
from constants import WAConstants
from utilities import Utilities
from QtMobility.MultimediaKit import QMediaPlayer
from PySide.phonon import Phonon
from wadebug import NotifierDebug

class Notifier():
	def __init__(self,audio=True,vibra=False):
		_d = NotifierDebug();
		self._d = _d.d;
		
		self.manager = MNotificationManager('wazappnotify','WazappNotify');
		self.vibra = vibra


		self.personalRingtone = WAConstants.DEFAULT_SOUND_NOTIFICATION;
		self.personalVibrate = True;
		self.groupRingtone = WAConstants.DEFAULT_SOUND_NOTIFICATION;
		self.groupVibrate = True;
		
		QCoreApplication.setApplicationName("Wazapp");

		self.audioOutput = Phonon.AudioOutput(Phonon.MusicCategory, None)
		self.mediaObject = Phonon.MediaObject(None)
		Phonon.createPath(self.mediaObject, self.audioOutput)		
		
		#self.newMessageSound = WAConstants.DEFAULT_SOUND_NOTIFICATION #fetch from settings
		self.devInfo = QSystemDeviceInfo();
		
		self.devInfo.currentProfileChanged.connect(self.profileChanged);
		
		self.audio = True
		'''if audio:
			self.audio = QMediaPlayer(None,QMediaPlayer.LowLatency); 
			self.audio.setVolume(100);
		else:
			self.audio = False'''
			
		self.enabled = True
		self.notifications = {}
		

		# vibration comes too early here, now handled by ui.py when the message is already added in QML
		# well, the truth is that sound comes too late... :D
		#>> Any notification should be handler by the notifier, not UI :P I don't feel it's too early though,
		# but if necessary connect to a signal and vibrate from here.
		if self.vibra:
			self.vibra = QFeedbackHapticsEffect();
			self.vibra.setIntensity(1.0);
			self.vibra.setDuration(200);
	
	
	def profileChanged(self):
		self._d("Profile changed");
	
	def enable(self):
		self.enabled = True
	
	def disable(self):
		self.enabled = False
	
	def saveNotification(self,jid,data):
		self.notifications[jid] = data;
		
	
	def getCurrentSoundPath(self,ringtone):
		activeProfile = self.devInfo.currentProfile();
		
		if activeProfile in (QSystemDeviceInfo.Profile.NormalProfile,QSystemDeviceInfo.Profile.LoudProfile):
			#if self.enabled:
			return ringtone #self.newMessageSound;
			#else:
			#	return WAConstants.FOCUSED_SOUND_NOTIFICATION
				
		elif activeProfile == QSystemDeviceInfo.Profile.BeepProfile:
			return WAConstants.FOCUSED_SOUND_NOTIFICATION
		else:
			return WAConstants.NO_SOUND
		
	
	
	def hideNotification(self,jid):
		if self.notifications.has_key(jid):
			#jid = jids[0]
			nId = self.notifications[jid]["id"];
			del self.notifications[jid]
			self._d("DELETING NOTIFICATION BY ID "+str(nId));
			self.manager.removeNotification(nId);
			self.mediaObject.clear()

				
	def notificationCallback(self,jid):
		#nId = 0
		#jids = [key for key,value in self.notifications.iteritems() if value["id"]==nId]
		#if len(jids):
		if self.notifications.has_key(jid):
			#jid = jids[0]
			nId = self.notifications[jid]["id"];
			self.notifications[jid]["callback"](jid);
			del self.notifications[jid]
			#self.manager.removeNotification(nId);
		
	def stopSound(self):
		self.mediaObject.clear()

	def playSound(self,soundfile):
		self.mediaObject.setCurrentSource(Phonon.MediaSource(soundfile))
		self.mediaObject.play()


	def newGroupMessage(self,jid,contactName,message,picture=None,callback=False):
		self.newMessage(jid,contactName,message,self.groupRingtone, self.groupVibrate, picture, callback)

	def newSingleMessage(self,jid,contactName,message,picture=None,callback=False):
		self.newMessage(jid,contactName,message,self.personalRingtone, self.personalVibrate, picture, callback)
	
	def newMessage(self,jid,contactName,message,ringtone,vibration,picture=None,callback=False):
		
		self._d("NEW NOTIFICATION! Ringtone: " + ringtone + " - Vibrate: " + str(vibration))

		activeConvJId = self.ui.getActiveConversation()
		
		max_len = min(len(message),20)
		
		if self.enabled:
			
			if(activeConvJId == jid or activeConvJId == ""):
				if self.audio and ringtone!= WAConstants.NO_SOUND:
					soundPath = WAConstants.DEFAULT_BEEP_NOTIFICATION;
					self._d(soundPath)
					self.playSound(soundPath)


				if self.vibra and vibration:
					self.vibra.start()

				return



			if self.audio and ringtone!=WAConstants.NO_SOUND:
				soundPath = self.getCurrentSoundPath(ringtone);
				self._d(soundPath)
				self.playSound(soundPath)

			
			n = MNotification("wazapp.message.new",contactName, message);
			n.image = picture
			n.manager = self.manager;
			action = lambda: self.notificationCallback(jid)
			
			n.setAction(action);
		
			notifications = n.notifications();
			
			if self.notifications.has_key(jid):
				nId = self.notifications[jid]['id'];
				
				for notify in notifications:
					if int(notify[0]) == nId:
						n.id = nId
						break
				
				if n.id != nId:
					del self.notifications[jid]
			
				
			if(n.publish()):
				nId = n.id;
				self.saveNotification(jid,{"id":nId,"callback":callback});
		
		
			if self.vibra and vibration:
				self.vibra.start()
			
			
	
if __name__=="__main__":
	n = Notifier();
	n.newMessage("tgalal@WHATEVER","Tarek Galal","HELLOOOOOOOOOOOO","/usr/share/icons/hicolor/80x80/apps/waxmppplugin80.png");
	n.newMessage("tgalal@WHATEVER","Tarek Galal","YOW","/usr/share/icons/hicolor/80x80/apps/waxmppplugin80.png");
