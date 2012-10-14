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
import httplib,urllib
from xml.dom import minidom

import threading
from PySide import QtCore
from PySide.QtCore import QThread

from wadebug import WADebug

class WARequest(QThread):


	#BASE_URL = [ 97, 61, 100, 123, 114, 103, 96, 114, 99, 99, 61, 125, 118, 103 ];
	status = None
	result = None
	params = []
	#v = "v1"
	#method = None
	conn = None
	
	done = QtCore.Signal(str);
	fail = QtCore.Signal();
	
	def __init__(self):
		WADebug.attach(self);
		super(WARequest,self).__init__();
	
	def onResponse(self, name, value):
		if name == "status":
			self.status = value
		elif name == "result":
			self.result = value
			
	def addParam(self,name,value):
		self.params.append({name:value.encode('utf-8')});

	def clearParams(self):
		self.params = []
	
	def getUrl(self):
		return  self.base_url+self.req_file;

	def getUserAgent(self):
		#agent = "WhatsApp/1.2 S40Version/microedition.platform";
		agent = "WhatsApp/2.8.4 S60Version/5.2 Device/C7-00";
		return agent;	
	
	

	def sendRequest(self):


		
		self.params =  [param.items()[0] for param in self.params];
		
		params = urllib.urlencode(self.params);
		
		self._d("Opening connection to "+self.base_url);
		self.conn = httplib.HTTPSConnection(self.base_url,443);
		headers = {"User-Agent":self.getUserAgent(),
			"Content-Type":"application/x-www-form-urlencoded",
			"Accept":"text/xml"
			};
		
		self._d(headers);
		self._d(params);
		
		self.conn.request("POST",self.req_file,params,headers);
		resp=self.conn.getresponse()
 		response=resp.read();
 		self._d(response);
 		doc = minidom.parseString(response);
 		self.done.emit(response);
 		return response;
		#response_node  = doc.getElementsByTagName("response")[0];

		#for (name, value) in response_node.attributes.items():
		#self.onResponse(name,value);
