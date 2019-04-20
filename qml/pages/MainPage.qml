import QtQuick 2.0
import Sailfish.Silica 1.0
import net.toxip.openccqml 1.0

Page {
    id: page
    property string cntext: ""
    property bool isIdiomsOn: idiomSwitch.enabled ? idiomSwitch.checked : false
    property bool idiomsEnabled: from.currentIndex === 0 && to.currentIndex === 2
                              || from.currentIndex === 2 && to.currentIndex === 0

    OpenCC {
        id: opencc
    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        // Place our content in a Column.  The PageHeader is always placed at the top
        // of the page, followed by our content.
        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("SailHanzi")
            }

            Row {
                width: parent.width
                
                ComboBox {
                    id: from
                    width: (parent.width - swap.width)* 0.5
                    // A stupid hack to force value on second row
                    label: qsTr("From          ​​")
                    menu: ContextMenu {
                        MenuItem { text: qsTr("Simplified") }
                        MenuItem { text: qsTr("Traditional") }
                        MenuItem { text: qsTr("Taiwanese") }
                        MenuItem { text: qsTr("Hong Kong") }
                    }
                }

                IconButton {
                    id: swap
                    width: Theme.itemSizeSmall
                    // A hack that puts the button in the vertical center
                    // even when either combobox is open
                    y: Math.min(from.height, to.height) / 2 - height / 2
                    icon.source: "image://theme/icon-m-sync?" + (pressed
                        ? Theme.highlightColor
                        : Theme.primaryColor)
                    onClicked: swapCharacters()
                }


                ComboBox {
                    id: to
                    width: (parent.width - swap.width)* 0.5
                    // A stupid hack to force value on second row
                    label: qsTr("To          ")
                    currentIndex: 2
                    menu: ContextMenu {
                        MenuItem { text: qsTr("Simplified") }
                        MenuItem { text: qsTr("Traditional") }
                        MenuItem { text: qsTr("Taiwanese") }
                        MenuItem { text: qsTr("Hong Kong") }
                    }
                }
            }

            TextSwitch {
                id: idiomSwitch
                text: qsTr("Translate idioms")
                description: qsTr("Enables translation of Mainland Chinese idioms into Taiwanese and vice versa.")
                enabled: idiomsEnabled
            }

            TextArea {
                id: sourceText
                width: parent.width
                text: ""
                placeholderText: qsTr("Enter Chinese text to convert...")
                label: qsTr("Source text")
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter

                IconButton {
                    id: swapTextButton
                    icon.source: "image://theme/icon-m-up?" + (pressed
                        ? Theme.highlightColor
                        : Theme.primaryColor)
                    enabled: resultText.text !== ""
                    onClicked: {
                        sourceText.text = resultText.text
                    }
                }
                Button {
                    id: convertButton
                    enabled: sourceText.text !== ""
                    text: qsTr("Convert")
                    onClicked: convertText(constructMode(from.currentIndex, to.currentIndex, isIdiomsOn), sourceText.text)
                }

                IconButton {
                    id: clearButton
                    icon.source: "image://theme/icon-m-clear?" + (pressed
                        ? Theme.highlightColor
                        : Theme.primaryColor)
                    enabled: sourceText.text !== ""
                    onClicked: {
                        sourceText.text = ""
                        resultText.text = ""
                        sourceText.forceActiveFocus()
                    }
                }
            }

            TextArea {
                id: resultText
                width: parent.width
                text: cntext
                placeholderText: qsTr("Conversion results")
                label: qsTr("Conversion results")
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
            }
        }
    }

    function convertText(mode, inputText) {
        opencc.chooseMode(mode)
        var newText = opencc.convert(inputText)
        cntext = newText
    }

    function constructMode(from, to, idiomsOn) {
        var modeArr = ["s","t","tw","hk"]
        var modeString = modeArr[from] + "2" + modeArr[to]
        if (isIdiomsOn) {
            modeString += "p"
        }
        return modeString
    }

    function swapCharacters() {
        var tmp = from.currentIndex
        from.currentIndex = to.currentIndex
        to.currentIndex = tmp
    }
}
