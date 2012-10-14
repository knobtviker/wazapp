/***************************************************************************
**
** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im>
**
** This file is part of Wazapp, an IM application for Meego Harmattan
** platform that allows communication with Whatsapp users.
**
** Wazapp is free software: you can redistribute it and/or modify it under
** the terms of the GNU General Public License as published by the
** Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** Wazapp is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
** See the GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with Wazapp. If not, see http://www.gnu.org/licenses/.
**
****************************************************************************/
// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

Rectangle {
    width: parent.width
    height: 2
    color:"transparent"

    Rectangle {
        id: sortingDivisionLine
        anchors.verticalCenter: parent.verticalCenter
		x:0
		width: parent.width
        height: 1
        color: "gray"
        opacity: 0.3
    }

	Rectangle {
        anchors.top: sortingDivisionLine.bottom
		x:0
		width: parent.width
        height: 1
        color: theme.inverted? "darkgray" : "white"
        opacity: theme.inverted? 0.3 : 0.5
    }

}
