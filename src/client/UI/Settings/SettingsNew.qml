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
import QtQuick 1.1
import com.nokia.meego 1.0
import "../common/js/settings.js" as MySettings
import "../common"

WAPage {
    id: root

	signal syncClicked();

    //property int bubbleColor:1
	property string currentTab: "general"
	property string contactPicture: "/home/user/.cache/wazapp/profile/" + myAccount.split("@")[0] + ".jpg"

	property string message: qsTr("This is a %1 version.").arg(waversiontype) + "\n" + 
							 qsTr("You are trying it at your own risk.") + "\n" + 
							 qsTr("Please report any bugs to") + "\n" + "tarek@wazapp.im"


    Component.onCompleted: {
		MySettings.initialize()
        syncClicked.connect(onSyncClicked)
    }

    tools: ToolBarLayout {
        id: toolBar

        ToolIcon {
            platformIconId: "toolbar-back"
            onClicked: pageStack.pop()
        }

        ToolButton
        {
			anchors.horizontalCenter: parent.horizontalCenter
			width: 300
            text: qsTr("Quit Wazapp")
            onClicked: appWindow.quitInit()
        }

		/*ToolIcon
        {
            iconSource: "../common/images/about" + (theme.inverted ? "-white" : "") + ".png";
            onClicked: { aboutDialog.open() }
        }*/
    }

	TextFieldStyle {
        id: myTextFieldStyle
        backgroundSelected: ""
        background: ""
		backgroundDisabled: ""
		backgroundError: ""
    }

    QueryDialog {
        property string phone_number;
        id:aboutDialog
        //anchors.fill: parent
        icon: "../common/images/icons/wazapp80.png"
        titleText: "Wazapp" //This should not be translated!
        message: qsTr("version") + " " + waversion + "\n\n" + 
                 qsTr("This is a %1 version.").arg(waversiontype) + "\n" + 
				 qsTr("You are trying it at your own risk.") + "\n" + 
				 qsTr("Please report any bugs to") + "\n" + "tarek@wazapp.im"
 
    }

	WAHeader{
        title: qsTr("Settings")
        anchors.top:parent.top
        width:parent.width
		height: 72
    }

	ButtonRow {
	    anchors.top: parent.top
	    anchors.topMargin: 72
		width: parent.width
		height: 70

        Button {
            platformStyle: TabButtonStyle { inverted: theme.inverted }
            //text: qsTr("General")
            iconSource: "image://theme/icon-m-toolbar-settings" + (theme.inverted? "-white":"")
            onClicked: currentTab = "general"
        }

        Button {
            platformStyle: TabButtonStyle { inverted: theme.inverted }
            //text: qsTr("Appearance")
            iconSource: "image://theme/icon-m-toolbar-pages-all" + (theme.inverted? "-white":"")
            onClicked: currentTab = "appearance"
        }

        /*Button {
            platformStyle: TabButtonStyle { inverted: theme.inverted }
            //text: qsTr("Notifications")
            iconSource: "image://theme/icon-m-toolbar-new-message" + (theme.inverted? "-white":"")
            onClicked: currentTab = "notifications"
        }*/

        Button {
            platformStyle: TabButtonStyle { inverted: theme.inverted }
            //text: qsTr("Mi Profile")
            iconSource: "image://theme/icon-m-toolbar-contact" + (theme.inverted? "-white":"")
            onClicked: currentTab = "profile"
        }

        /*Button {
            platformStyle: TabButtonStyle { inverted: theme.inverted }
            //text: qsTr("Blocked")
            iconSource: "image://theme/icon-m-toolbar-close" + (theme.inverted? "-white":"")
            onClicked: currentTab = "blocked"
        }*/

        Button {
            platformStyle: TabButtonStyle { inverted: theme.inverted }
            //text: qsTr("About")
            iconSource: "../common/images/about" + (theme.inverted ? "-white" : "") + ".png";
            onClicked: currentTab = "about"
        }


	}

	Item {
		id: generalTab
	    anchors.top: parent.top
	    anchors.topMargin: 142
	    height: parent.height -142
		anchors.left: parent.left
		anchors.leftMargin: 16
		width: parent.width -32
		visible: currentTab=="general"

		Flickable {
			id: flickArea1
			anchors.fill: parent
			contentWidth: width
			contentHeight: column.height + 40
			clip: true

			Column {
			    id: column
			    anchors { top: parent.top; left: parent.left; right: parent.right; }
			    spacing: 10


				GroupSeparator {
					title: qsTr("Chats")
				}
				SwitchItem {
					title: qsTr("Enter key sends the message")
					check: sendWithEnterKey
					onCheckChanged: {
						MySettings.setSetting("SendWithEnterKey", value)
						sendWithEnterKey = value=="Yes"
					}
				}

				GroupSeparator {
					title: qsTr("Media sending")
				}
				SwitchItem {
					title: qsTr("Resize images before sending")
					check: resizeImages
					onCheckChanged: {
						MySettings.setSetting("ResizeImages", value)
						resizeImages = value=="Yes"
						setResizeImages(resizeImages)
					}
				}

				GroupSeparator {
					title: qsTr("Language")
				}
			    SelectionItemTr {
			        title: qsTr("Current language")
			        model: ListModel {
			            ListElement { name: "Chinese"; value: "zh" }
			            ListElement { name: "Chinese (Taiwan)"; value: "zh_TW" }
			            ListElement { name: "Czech (Czech Republic)"; value: "cs_CZ" }
			            ListElement { name: "Dutch"; value: "nl" }
			            ListElement { name: "English"; value: "en" }
			            ListElement { name: "English (United Kingdom)"; value: "en_GB" }
			            ListElement { name: "French (France)"; value: "fr_FR" }
			            ListElement { name: "German (Germany)"; value: "de_DE" }
			            ListElement { name: "Italian"; value: "it" }
			            ListElement { name: "Portuguese (Brazil)"; value: "pt_BR" }
			            ListElement { name: "Portuguese (Portugal)"; value: "pt_PT" }
			            ListElement { name: "Romanian"; value: "ro" }
			            ListElement { name: "Russian"; value: "ru" }
			            ListElement { name: "Russian (Russia)"; value: "ru_RU" }
			            ListElement { name: "Spanish (Argentina)"; value: "es_AR" }
			            ListElement { name: "Spanish (Mexico)"; value: "es_MX" }
			            ListElement { name: "Swedish (Finland)"; value: "sv_FI" }
			            ListElement { name: "Turkish (Turkey)"; value: "tr_TR" }
			        }
					initialValue: MySettings.getSetting("Language", "en")
			        onValueChosen: { 
						MySettings.setSetting("Language", value)
						setLanguage(value)
					}
			    }
				Label {
					id: subTitle
					color: "gray"
					verticalAlignment: Text.AlignVCenter
					text: qsTr("*Restart Wazapp to apply the new language")
					font.pixelSize: 20
				}


			}

		}

		ScrollDecorator {
			flickableItem: flickArea1
		}

	}

	Item {
		id: appearanceTab
	    anchors.top: parent.top
	    anchors.topMargin: 142
	    height: parent.height -142
		anchors.left: parent.left
		anchors.leftMargin: 16
		width: parent.width -32
		visible: currentTab=="appearance"

		Flickable {
			id: flickArea2
			anchors.fill: parent
			contentWidth: width
			contentHeight: column2.height + 40
			clip: true

			Column {
			    id: column2
			    anchors { top: parent.top; left: parent.left; right: parent.right;}
			    spacing: 10

				/*GroupSeparator {
					title: qsTr("Whatsapp")
				}

				Rectangle {
					color: "transparent"
					width: parent.width
					height: 40
					Label {
						width: parent.width
						anchors.verticalCenter: parent.verticalCenter
						text: qsTr("Server status:")
					}
					Label {
						width: parent.width
						anchors.verticalCenter: parent.verticalCenter
						horizontalAlignment: Text.AlignRight
						text: qsTr("Online")
						color: "green"
					}
			    
				}*/

				/*Button {
					width: parent.width
					text: qsTr("Sync contacts")
					onClicked: { console.log("SYNC"); syncClicked(); }
				}

				GroupSeparator {
					title: qsTr("Status")
				}
				Button {
					width: parent.width
					onClicked: pageStack.push (Qt.resolvedUrl("../ChangeStatus/ChangeStatus.qml"))
					text: qsTr("Change status")
			    }*/

				GroupSeparator {
					title: qsTr("Appearance")
				}
				Label {
					verticalAlignment: Text.AlignBottom
					text: qsTr("Orientation:")
					height: 30
				}
				ButtonRow {
			        Button {
			            text: qsTr("Automatic")
			            checked: orientation==0
			            onClicked: {
							MySettings.setSetting("Orientation", "0")
			                orientation=0
			            }
			        }
			        Button {
			            text: qsTr("Portrait")
			            checked: orientation==1
			            onClicked: {
							MySettings.setSetting("Orientation", "1")
			                orientation=1
			            }
			        }
			        Button {
			            text: qsTr("Landscape")
			            checked: orientation==2
			            onClicked: {
							MySettings.setSetting("Orientation", "2")
			                orientation=2
			            }
			        }
			    }

				Label {
					verticalAlignment: Text.AlignBottom
					text: qsTr("Theme color:")
					height: 50
				}
				ButtonRow {
			        id: br1
			        Button {
			            text: qsTr("White")
			            checked: theme.inverted ? false : true
			            //platformStyle: myButtonStyleLeft
			            onClicked: {
							MySettings.setSetting("ThemeColor", "White")
			                theme.inverted = false
			            }
			        }
			        Button {
			            text: qsTr("Black")
			            checked: theme.inverted ? true : false
			            //platformStyle: myButtonStyleRight
			            onClicked: {
							MySettings.setSetting("ThemeColor", "Black")
			                theme.inverted = true
			            }
			        }
			    }
				Label {
					verticalAlignment: Text.AlignBottom
					text: qsTr("Bubble color:")
					height: 50
				}
				ButtonRow {
			        id: br2
					height: 70
			        Button {
			            text: qsTr("Cyan")
			            checked: mainBubbleColor==1
			            onClicked: {
							MySettings.setSetting("BubbleColor", "1")
			                mainBubbleColor=1
			            }
			        }
			        Button {
			            text: qsTr("Green")
			            checked: mainBubbleColor==4
			            onClicked: {
							MySettings.setSetting("BubbleColor", "4")
			                mainBubbleColor=4
			            }
			        }
			        Button {
			            text: qsTr("Pink")
			            checked: mainBubbleColor==3
			            onClicked: {
							MySettings.setSetting("BubbleColor", "3")
			                mainBubbleColor=3
			            }
			        }
			        Button {
			            text: qsTr("Orange")
			            checked: mainBubbleColor==2
			            onClicked: {
							MySettings.setSetting("BubbleColor", "2")
			                mainBubbleColor=2
			            }
			        }
			    }

			}

		}

		ScrollDecorator {
			flickableItem: flickArea2
		}

	}



	Item {
		id: profileTab
	    anchors.top: parent.top
	    anchors.topMargin: 142
	    height: parent.height -142
		anchors.left: parent.left
		anchors.leftMargin: 16
		width: parent.width -32
		visible: currentTab=="profile"

		Flickable {
			id: flickArea4
			anchors.fill: parent
			contentWidth: width
			contentHeight: column4.height + 20
			anchors.centerIn: parent
			clip: true

			Image {
				id: bigImage
				visible: false
				source: contactPicture
				cache: false
			}

			Column {
			    id: column4
				width: parent.width
				anchors { top: parent.top; left: parent.left; right: parent.right;}
			    spacing: 24

				GroupSeparator {
					title: qsTr("Profile picture")
				}

				ProfileImage {
					id: picture
					size: 140
					height: size
					width: size
					imgsource: bigImage.height>0 ? contactPicture : "../common/images/user.png"
					onClicked: { 
						if (bigImage.height>0) 
							bigProfileImage = contactPicture
							pageStack.push (Qt.resolvedUrl("../common/BigProfileImage.qml"))
							//Qt.openUrlExternally(contactPicture.replace(".png",".jpg").replace("contacts","profile"))
					}
					anchors.horizontalCenter: parent.horizontalCenter
				}

				Button {
					height: 50
					width: parent.width
					font.pixelSize: 22
					text: qsTr("Change picture")
				    onClicked: {
						profileUser = myAccount
						pageStack.push(setProfilePicture)
					}
				}

				GroupSeparator {
					title: qsTr("Status")
				}

			    SelectionItem {
					id: statusText
			        title: qsTr("Change current status")
			        initialValue: MySettings.getSetting("Status", "Hi there I'm using Wazapp")
			        onClicked: pageStack.push (Qt.resolvedUrl("../ChangeStatus/ChangeStatus.qml"))
			    }

				Connections {
					target: appWindow
					onOnContactPictureUpdated: {
						if (myAccount == ujid) {
							contactPicture = "/home/user/.cache/wazapp/contacts/" + myAccount.split("@")[0] + ".jpg"
							picture.imgsource = ""
							picture.imgsource = contactPicture
							bigImage.source = ""
							bigImage.source = contactPicture
						}
					}
					onStatusChanged: {
						statusText.initialValue = MySettings.getSetting("Status", "Hi there I'm using Wazapp")
					}
				}

			    
			}

		}

		ScrollDecorator {
			flickableItem: flickArea4
		}

	}





	Item {
		id: aboutTab
	    anchors.top: parent.top
	    anchors.topMargin: 142
	    height: parent.height -142
		anchors.left: parent.left
		anchors.leftMargin: 16
		width: parent.width -32
		visible: currentTab=="about"

		Flickable {
			id: flickArea6
			anchors.fill: parent
			contentWidth: width
			contentHeight: column6.height + 20
			anchors.centerIn: parent
			clip: true

			Column {
			    id: column6
				width: parent.width
				anchors { top: parent.top; left: parent.left; right: parent.right;}
			    spacing: 24

				GroupSeparator {
					title: qsTr("About")
				}


				Image {
					source: "../common/images/icons/wazapp80.png"
					anchors.horizontalCenter: parent.horizontalCenter
				}

				Label {
					horizontalAlignment: Text.AlignHCenter
					anchors.leftMargin: 16
					width: parent.width -32
					text: "Wazapp"
				}

				Label {
					horizontalAlignment: Text.AlignHCenter
					anchors.leftMargin: 16
					width: parent.width -32
					text: qsTr("version") + " " + waversion
				}

				Label {
					horizontalAlignment: Text.AlignHCenter
					anchors.leftMargin: 16
					width: parent.width -32
					text: message
				}
			    
			}

		}

		ScrollDecorator {
			flickableItem: flickArea6
		}

	}
}

