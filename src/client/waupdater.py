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
from wajsonrequest import WAJsonRequest
from PySide import QtCore
from distutils.version import StrictVersion
from utilities import Utilities

from wadebug import UpdaterDebug;

class WAUpdater(WAJsonRequest):
	updateAvailable = QtCore.Signal(dict)
	
	def __init__(self):
		_d = UpdaterDebug();
		self._d = _d.d
		
		self.base_url = "wazapp.im"
		self.req_file = "/whatsup/"
		
	
		super(WAUpdater,self).__init__();
	
	def run(self):
		self._d("Checking for updates")
		res = None #self.sendRequest()
		if res:
			#current = self.version.split('.');
			#latest = res['v'].split('.')
			curr = Utilities.waversion
			test = curr.split('.');
			
			if len(test) == 4:
				curr = '.'.join(test[:3])
				
			if StrictVersion(str(res['l'])) > curr:
				self._d("UPDATE AVAILABLE!")
				self.updateAvailable.emit(res)
