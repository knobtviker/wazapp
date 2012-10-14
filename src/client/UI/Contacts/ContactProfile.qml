/*************************************************************************** ** ** Copyright (c) 2012, Tarek Galal <tarek@wazapp.im> ** ** This file 
is part of Wazapp, an IM application for Meego Harmattan ** platform that allows communication with Whatsapp users. ** ** Wazapp is free software: 
you can redistribute it and/or modify it under ** the terms of the GNU General Public License as published by the ** Free Software Foundation, either 
version 2 of the License, or ** (at your option) any later version. ** ** Wazapp is distributed in the hope that it will be useful, ** but WITHOUT 
ANY WARRANTY; without even the implied warranty of ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. ** See the GNU General Public License for 
more details. ** ** You should have received a copy of the GNU General Public License ** along with Wazapp. If not, see http://www.gnu.org/licenses/. 
** ****************************************************************************/ 
//import QtQuick 1.0 // to target S60 5th Edition or Maemo 5 
import QtQuick 1.1 
import com.nokia.meego 1.0 
import "../common/js/Global.js" as Helpers 
import "../common"

WAPage {
    id:container

    Component.onCompleted: {
            getInfo("YES")
    }
    tools: ToolBarLayout {
        id: toolBar
        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: {
		pageStack.pop()
	    }
        }
    }

    property string contactJid   
    property string contactName
    property string contactNumber
    property string contactPicture: "../common/images/user.png"
    property string contactStatus
    property bool inContacts
    property alias contactMedia: mediaList.model
    property alias contactGroups: groupsRepeater.model

    onStatusChanged: {
        if(status == PageStatus.Activating){
             getPictureIds(contactJid)
        }
    }

    function findChatIem(jid){
        for (var i=0; i<conversationsModel.count;i++) {
            var chatItem = conversationsModel.get(i);
            if(chatItem.conversation.jid == jid)
                   return  i;
        }
        return -1;
    }

    function removeChatItem(jid){
        var chatItemIndex = findChatIem(jid);
        consoleDebug("deleting")
        if(chatItemIndex >= 0){
            var conversation = conversationsModel.get(chatItemIndex).conversation;
            var contacts = conversation.getContacts();
            for(var i=0; i<contacts.length; i++){
                contacts[i].unsetConversation();
            }
            delete conversation;
            conversationsModel.remove(chatItemIndex);
            checkUnreadMessages()
        }
    }

    function getInfo(updatepicture) {
        for(var i =0; i<contactsModel.count; i++) {
            if(contactsModel.get(i).jid == profileUser) {
                contactPicture = contactsModel.get(i).picture
                contactName = contactsModel.get(i).name
                contactStatus = contactsModel.get(i).status? contactsModel.get(i).status : ""
                contactNumber = contactsModel.get(i).number
                inContacts = contactsModel.get(i).iscontact=="yes"
                bigImage.source = ""
                bigImage.source = WAConstants.CACHE_PROFILE + "/" + profileUser.split('@')[0] + ".jpg"
                break;
            }
        }
        if (contactName == "") {
                contactName = qsTr("Unknown contact")
                contactNumber = profileUser.split('@')[0]
        }
        if (updatepicture=="YES")
                getPictureIds(profileUser)
    }

    ButtonStyle {
        id: buttonStyleTop
        property string __invertedString: theme.inverted ? "-inverted" : ""
        pressedBackground: "image://theme/color3-meegotouch-button-background-pressed-vertical-top"
        checkedBackground: "image://theme/color3-meegotouch-button-background-selected-vertical-top"
        disabledBackground: "image://theme/color3-meegotouch-button"+__invertedString+"-background-disabled-vertical-top"
        checkedDisabledBackground: "image://theme/color3-meegotouch-button"+__invertedString+"-background-disabled-selected-vertical-top"
    }
    ButtonStyle {
        id: buttonStyleCenter
        property string __invertedString: theme.inverted ? "-inverted" : ""
        pressedBackground: "image://theme/color3-meegotouch-button-background-pressed-vertical-center"
        checkedBackground: "image://theme/color3-meegotouch-button-background-selected-vertical-center"
        disabledBackground: "image://theme/color3-meegotouch-button"+__invertedString+"-background-disabled-vertical-center"
        checkedDisabledBackground: "image://theme/color3-meegotouch-button"+__invertedString+"-background-disabled-selected-vertical-center"
    }
    ButtonStyle {
        id: buttonStyleBottom
        property string __invertedString: theme.inverted ? "-inverted" : ""
        pressedBackground: "image://theme/color3-meegotouch-button-background-pressed-vertical-bottom"
        checkedBackground: "image://theme/color3-meegotouch-button-background-selected-vertical-bottom"
        disabledBackground: "image://theme/color3-meegotouch-button"+__invertedString+"-background-disabled-vertical-bottom"
        checkedDisabledBackground: "image://theme/color3-meegotouch-button"+__invertedString+"-background-disabled-selected-vertical-bottom"
    }

    QueryDialog {
        id: chatHistoryDelete
        titleText: qsTr("Confirm Delete")
        message: qsTr("Are you sure you want to delete this conversation and all its messages?")
        acceptButtonText: qsTr("Yes")
        rejectButtonText: qsTr("No")
        onAccepted: {
            deleteConversation(profileUser)
            removeChatItem(profileUser)
        }
    }

    Connections {
        target: appWindow
        onRefreshSuccessed: statusButton.enabled=true
        onRefreshFailed: statusButton.enabled=true
/*
        onOnContactPictureUpdated: {
            if (profileUser == ujid) {
                getInfo("NO")
                picture.imgsource = ""
                picture.imgsource = contactPicture
                bigImage.source = ""
                bigImage.source = WAConstants.CACHE_PROFILE + "/" + profileUser.split('@')[0] + ".jpg"
            }
        }
        onContactStatusUpdated: {
            if (contactForStatus == profileUser) {
                contactStatus = nstatus
                statuslabel.text = Helpers.emojify(contactStatus)
            }
        }
*/
    }

    Image {
        id: bigImage
        visible: false
        source: WAConstants.CACHE_PROFILE + "/" + profileUser.split('@')[0] + ".jpg"
        cache: false
    }

    Column {
        id: column1
        width: parent.width -32
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 12
        spacing: 12

        Row {
            width: parent.width
            height: col1.heigth + 48
            spacing: 10

            ProfileImage {
                id: picture
                size: 80
                height: size
                width: size
                y: 0
                imgsource: contactPicture=="none" ? "../common/images/user.png" : contactPicture
                onClicked: {
                    if (bigImage.width>0) {
                        Qt.openUrlExternally(bigImage.source)
                    }
                }
            }

            Column {
                id: col1
                width: parent.width - picture.size -10
                anchors.verticalCenter: parent.verticalCenter

                Label {
                    text: contactName
                    font.bold: true
                    font.pixelSize: 26
                    width: parent.width
                    elide: Text.ElideRight
                }

                Label {
                    id: statuslabel
                    font.pixelSize: 22
                    color: "gray"
                    visible: contactStatus!==""
                    text: Helpers.emojify(contactStatus)
                    width: parent.width
                }
            }
        }
    }
    Separator {
	id: mainSeparator
    	width: parent.width
	anchors.top: column1.bottom
    }
    Flickable {
        id: flickArea
        anchors.top: mainSeparator.bottom
        width: parent.width
        height: parent.height - column1.height-1
        contentWidth: parent.width
        contentHeight: buttonColumn.height+separator1.height+blockLabel.height+telephonyItem.height+separator2.height+groupsList.height+separator3.height+mediaList.height+36+(blockLabel.visible?12:0)
        clip: true

	BorderImage {
	    id: blockLabel
	    border { left: 22; right: 22; bottom: 22; top: 22; }
	    source: "image://theme/meegotouch-button-negative"+(theme.inverted?"-inverted":"")+"-background"
            width: parent.width-32
            visible: blockedContacts.indexOf(profileUser)!=-1
            height: visible ? 50 : 0
	    anchors.top: parent.top
            anchors.topMargin: 12
	    anchors.horizontalCenter: parent.horizontalCenter
            Label {
	        anchors.fill: parent
                text: qsTr("Contact blocked")
                font.bold: true
                font.pixelSize: 26
                color: "white"
                visible: blockedContacts.indexOf(profileUser)!=-1
                horizontalAlignment: Text.AlignHCenter
	        verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
	}

        ButtonColumn{
            id: buttonColumn
            width: parent.width-32
            anchors.top: blockLabel.bottom
	    anchors.topMargin: blockLabel.visible ? 12 : 0
	    anchors.horizontalCenter: parent.horizontalCenter

            Button {
                id: statusButton
                platformStyle: buttonStyleTop
                height: 50
                width: parent.width
                font.pixelSize: 22
                text: qsTr("Update status")
                visible: profileUser.indexOf("g.us")==-1
                onClicked: {
                        updateSingleStatus=true
                        statusButton.enabled=false
                        contactForStatus = profileUser
                        refreshContacts("STATUS", profileUser.split('@')[0])
                }
            }

            Button {
                id: blockButton
                platformStyle: buttonStyleCenter
                height: 50
                width: parent.width
                font.pixelSize: 22
                text: blockedContacts.indexOf(profileUser)==-1? qsTr("Block contact") : qsTr("Unblock contact")
                onClicked: {
                    if (blockedContacts.indexOf(profileUser)==-1)
                        blockContact(profileUser)
                    else
                        unblockContact(profileUser)
                }
            }

            Button {
                height: 50
                platformStyle: buttonStyleCenter
                width: parent.width
                font.pixelSize: 22
                text: qsTr("Add to contacts")
                visible: !inContacts
                onClicked: Qt.openUrlExternally("tel:"+contactNumber)
            }

            Button {
                id: sendChatButton
                platformStyle: buttonStyleCenter
                height: 50
                width: parent.width
                font.pixelSize: 22
                text: qsTr("Send chat history")
                onClicked: { exportConversation(profileUser); }
            }

            Button {
                id: deleteChatButton
                platformStyle: buttonStyleBottom
                height: 50
                width: parent.width
                font.pixelSize: 22
                text: qsTr("Delete chat history")
                onClicked: {
                    chatHistoryDelete.open()
                }
            }
        }

        GroupSeparator {
            id: separator3
            anchors.top: buttonColumn.bottom
            anchors.left: parent.left
            anchors.leftMargin: 16
            width: parent.width - 44
	    visible: mediaList.model.count == 0 ? false : true
            height: visible ? 50 : 0
            title: qsTr("Media")
        }

        ListView {
            id: mediaList

	    function mediaTypePicker(type) {
		var thumb = ""
	    	switch(type){
            	case 3: {
				thumb = "image://theme/icon-m-content-audio"+(theme.inverted?"-inverse":"")
				break
			}
            	case 4: {
				thumb = "image://theme/icon-m-content-videos"
				break
			}
            	case 5: {
				thumb = "../common/images/content-location.png"
				break
			}
            	case 6: {
				thumb = "image://theme/icon-m-content-avatar-placeholder"
				break
			}
        	}	
		return thumb
	    }
	    cacheBuffer: 100
            orientation: ListView.Horizontal
            width: parent.width -32
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: separator3.bottom
            height: separator3.visible ? 90 : 0
	    model: containter.mediaModel
            delegate: Rectangle {
			id: mediaDelgate
			property int prefixType: mediatype_id
			color: mediaMouseArea.pressed ? (theme.inverted? "darkgray" : "lightgray") : "transparent"
			opacity: mediaMouseArea.pressed ? (theme.inverted? 0.2 : 0.8) : 1.0
			height: parent.height 
			width: height
			RoundedImage {
				id: mediaPreview
				
				x: mediaList.height-height
				y: x
            			width: istate=="Loaded!" ? 86 : 0
            			size: istate=="Loaded!" ? 80 : 0
            			height: width
				//opacity: mediaMouseArea.pressed ? 0.8 : 1.0
				imgsource: preview ? "data:image/jpg;base64,"+preview : mediaList.mediaTypePicker(mediatype_id)
			}
			MouseArea {
				id: mediaMouseArea
				anchors.fill: parent
				onClicked: {
					var prefix = ""
					if (parent.prefixType == 5) {
						prefix = "geo:"
					} else {
						prefix = "file://"
					}
					Qt.openUrlExternally(prefix+local_path)
				}
			}
		}
        }

        GroupSeparator {
            id: separator2
            anchors.top: mediaList.bottom
            anchors.left: parent.left
            anchors.leftMargin: 16
            width: parent.width - 44
	    visible: groupsRepeater.model.count == 0 ? false : true
            height: visible ? 50 : 0
            title: qsTr("Groups")
        }

	Column {
            id: groupsList
            width: parent.width -32
	    clip: true
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: separator2.bottom
	    Repeater {
	    	id: groupsRepeater
		Rectangle {
			property string jidString: jid
			height: 104
			width: groupsList.width
			color: groupMouseArea.pressed? (theme.inverted?"darkgray":"lightgray"):"transparent"
			opacity: groupMouseArea.pressed? (theme.inverted? 0.2 : 0.8) : 1.0
			RoundedImage {
	 	        	id:picture
            			width:80
            			height: 80
            			size:72
            			imgsource: "file://"+pic
				anchors.verticalCenter: parent.verticalCenter
				anchors.left: parent.left
				anchors.leftMargin: 12
				//opacity:appWindow.stealth?0.2:1
		        }
			Label {
				id: subjectItem
				text: subject
				height: 40
				color: theme.inverted?"white":"black" 
				width: parent.width - picture.width - 24	
				elide: Text.ElideRight
		                font.bold: true
				font.pointSize: 18
                    		verticalAlignment: Text.AlignVCenter
				anchors.left: picture.right
				anchors.leftMargin: 12
				anchors.top: parent.top
				anchors.topMargin: 12
			}
			Label {
				id: contactsItem
				text: contacts
				elide: Text.ElideRight
                    		font.pixelSize: 20
				color: "gray"
                    		height: 40
				width: parent.width - picture.width - 24	
				verticalAlignment: Text.AlignVCenter
				anchors.left: picture.right
				anchors.leftMargin: subjectItem.anchors.leftMargin
				anchors.top: subjectItem.bottom
			}
			MouseArea {
				id: groupMouseArea
				anchors.fill: parent
				onClicked: {
					var conversation = waChats.getConversation(parent.jidString);
					conversation.open();
				}
			}		
		}	
            }
	}

        GroupSeparator {
            id: separator1
            anchors.top: groupsList.bottom
            anchors.left: parent.left
            anchors.leftMargin: 16
            width: parent.width - 44
            height: 50
            title: qsTr("Phone")
        }

        Item {
            id: telephonyItem
            anchors.top: separator1.bottom
	    anchors.left: parent.left
	    anchors.leftMargin: 16
            height: 84
            width: parent.width-32
            x: 0

            BorderImage {
		id: callLeft
                height: parent.height
                width: parent.width -80 -anchors.rightMargin
                x: 0; y: 0
	        anchors.right: smsRight.left
		anchors.rightMargin: -1 
		source: bArea.pressed?"image://theme/color3-meegotouch-button-background-pressed-horizontal-left":"image://theme/meegotouch-button"+(theme.inverted?"-inverted":"")+"-background-horizontal-left"
                border { left: 22; right: 22; bottom: 22; top: 22; }

                Label {
                    x: 20; y: 14
                    width: parent.width
                    font.pixelSize: 20
                    text: qsTr("Mobile phone")
                }
                Label {
                    x: 20; y: 40
                    width: parent.width
                    font.bold: true
                    font.pixelSize: 24
                    text: contactNumber
                }
		Rectangle {
		    width:1
	 	    color: theme.inverted?"gray":"darkgray"
		    anchors.right: parent.right
		    anchors.rightMargin: 1
		    anchors.verticalCenter: parent.verticalCenter
		    opacity: 0.9
		    height: parent.height-12
		}
                MouseArea {
                    id: bArea
                    anchors.fill: parent
                    onClicked: makeCall("+"+contactNumber)
                }
            }

            BorderImage {
		id: smsRight
                height: parent.height
                anchors.right: parent.right
                width: 80
                x: 0; y: 0
		source: bcArea.pressed?"image://theme/color3-meegotouch-button-background-pressed-horizontal-right":"image://theme/meegotouch-button"+(theme.inverted?"-inverted":"")+"-background-horizontal-right"
                border { left: 22; right: 22; bottom: 22; top: 22; }

                Image {
                    x: 18
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/icon-m-toolbar-new-message"+(theme.inverted?"-white":"")
                }
                MouseArea {
                    id: bcArea
                    anchors.fill: parent
                    onClicked: sendSMS(contactNumber)
                }
            }
        }
    }
}
