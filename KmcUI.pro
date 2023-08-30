TEMPLATE = lib
QT += qml quick
CONFIG += plugin qmltypes

TARGET = $$qtLibraryTarget(KmcUI)

QML_IMPORT_NAME = KmcUI
QML_IMPORT_VERSION = 1.0

## Input
RESOURCES += \
    kmc_resources.qrc

HEADERS += \
    src/treenode.h \
    src/treemodel.h \
    src/foldertreemodel.h \
    src/kmcuiplugin.h

SOURCES += \
    src/treenode.cpp \
    src/treemodel.cpp \
    src/foldertreemodel.cpp

INCLUDEPATH += \
    src

DESTDIR = $$PWD/../../bin/$$QML_IMPORT_NAME

KMC_FILES += \
    src/imports/KmcUI/ColorIcon.qml \
    src/imports/KmcUI/IconData.qml \
    src/imports/KmcUI/KmcUI.qml \
    src/imports/KmcUI/qmldir

WINDOW_FILES += \
    src/imports/KmcUI/Window/FlipableWindow.qml \
    src/imports/KmcUI/Window/ShadowWindow.qml \
    src/imports/KmcUI/Window/WindowBackground.qml \
    src/imports/KmcUI/Window/qmldir

CONTROLS_FILES += \
    src/imports/KmcUI/Controls/AnchorToolTip.qml \
    src/imports/KmcUI/Controls/AppBar.qml \
    src/imports/KmcUI/Controls/BubbleToolTip.qml \
    src/imports/KmcUI/Controls/IconData.qml \
    src/imports/KmcUI/Controls/KeySequenceText.qml \
    src/imports/KmcUI/Controls/KmcTreeView.qml \
    src/imports/KmcUI/Controls/KmcTreeView2.qml \
    src/imports/KmcUI/Controls/KmcTreeViewDelegate.qml \
    src/imports/KmcUI/Controls/KmcTreeViewDelegate2.qml \
    src/imports/KmcUI/Controls/MouseToolTip.qml \
    src/imports/KmcUI/Controls/PopupComboBox.qml \
    src/imports/KmcUI/Controls/TitleBar.qml \
    src/imports/KmcUI/Controls/TreeViewItem.qml \
    src/imports/KmcUI/Controls/WndMouseToolTip.qml \
    src/imports/KmcUI/Controls/qmldir

EFFECTS_FILES += \
    src/imports/KmcUI/Effects/ClipMask.qml \
    src/imports/KmcUI/Effects/RectangularGlow.qml \
    src/imports/KmcUI/Effects/qmldir



DESTPATH=$$PWD/$$QML_IMPORT_NAME

target.path = $$DESTPATH
qmldir.files = qmldir
qmldir.path = $$DESTPATH
INSTALLS += target qmldir

CONFIG += install_ok

copy_kmc.files += $$KMC_FILES $$OUT_PWD/plugins.qmltypes
copy_kmc.path = $$DESTDIR

copy_controls.files += $$CONTROLS_FILES
copy_controls.path = $$DESTDIR/Controls

copy_window.files += $$WINDOW_FILES
copy_window.path = $$DESTDIR/Window

copy_effects.files += $$EFFECTS_FILES
copy_effects.path = $$DESTDIR/Effects

COPIES += copy_kmc copy_controls copy_window copy_effects



