QML_IMPORT_NAME = "KmcUI"
QML_IMPORT_MAJOR_VERSION = 1

from PySide6.QtCore import (QObject, Property, Qt, Signal, ClassInfo, Slot,
                            QAbstractItemModel, QModelIndex)
from PySide6.QtQml import QmlNamedElement, ListProperty


@QmlNamedElement("KmcTreeNode")
@ClassInfo(DefaultProperty="childNodes")
class TreeNode(QObject):
    dataChanged = Signal(int)

    def __init__(self, parent=None):
        super().__init__(parent)
        self._itemData = {}
        self._childNodes = []

    def setData(self, value, role=Qt.DisplayRole):
        self._itemData[role] = value
        self.dataChanged.emit(role)

    @Property("QVariant", fset=setData, notify=dataChanged, final=True)
    def data(self):
        return self._itemData.get(Qt.DisplayRole)

    def parentItem(self) -> 'TreeNode':
        return self.parent()

    def insertChildren(self, position: int, count: int, columns: int) -> bool:
        if position < 0 or position > len(self._childNodes):
            return False

        for row in range(count):
            self._childNodes.insert(position, TreeNode(self))

        return True

    def removeChildren(self, position: int, count: int) -> bool:
        if position < 0 or position + count > len(self._childNodes):
            return False

        for row in range(count):
            self._childNodes.pop(position)

        return True

    def row(self):
        if self.parentItem() is not None:
            return self.parentItem()._childNodes.index(self)
        return 0

    def child(self, n):
        return self._childNodes[n]

    def appendNode(self, node: 'TreeNode'):
        self._childNodes.append(node)

    def removeNode(self, node: 'TreeNode'):
        self._childNodes.remove(node)

    def clear(self):
        self._childNodes.clear()

    def childCount(self):
        return len(self._childNodes)
    
    def childNumber(self) -> int:
        if self.parentItem():
            return self.parentItem()._childNodes.index(self)
        return 0

    def __repr__(self) -> str:
        result = f"<PyKmc.models.TreeNode at 0x{id(self):x}"
        for d in self._itemData:
            result += f' "{d}"' if d else " <None>"
        result += f", {len(self._childNodes)} children>"
        return result

    childNodes = ListProperty(QObject, appendNode, child, clear, childCount)


@QmlNamedElement("KmcTreeModel")
@ClassInfo(DefaultProperty="topItems")
class TreeModel(QAbstractItemModel):

    def __init__(self, parent=None):
        super().__init__(parent)
        self._rootItem = TreeNode(parent)

    def getItem(self, index: QModelIndex = QModelIndex()) -> TreeNode:
        if index.isValid():
            item: TreeNode = index.internalPointer()
            if item:
                return item

        return self._rootItem

    def rowCount(self, parent=None):
        return self.getItem(parent).childCount()

    def columnCount(self, parent=None) -> int:
        return 1

    def parent(self, index: QModelIndex = QModelIndex()) -> QModelIndex:
        if not index.isValid():
            return QModelIndex()

        childItem: TreeNode = self.getItem(index)
        parentItem: TreeNode = childItem.parent()

        if parentItem == self._rootItem or not parentItem:
            return QModelIndex()

        return self.createIndex(parentItem.childNumber(), 0, parentItem)

    def index(self, row: int, column: int,
              parent: QModelIndex = QModelIndex()) -> QModelIndex:
        if parent.isValid() and parent.column() != 0:
            return QModelIndex()

        parentItem: TreeNode = self.getItem(parent)
        childItem: TreeNode = parentItem.child(row)
        if childItem:
            return self.createIndex(row, column, childItem)
        return QModelIndex()

    def data(self, index: QModelIndex, role: int = None):
        if not index.isValid():
            return None

        if role != Qt.DisplayRole and role != Qt.EditRole:
            return None

        return self.getItem(index).data(role)

    def insertRows(self,
                   position: int,
                   rows: int,
                   parent: QModelIndex = QModelIndex()) -> bool:
        parentItem: TreeNode = self.getItem(parent)
        if not parentItem:
            return False

        self.beginInsertRows(parent, position, position + rows - 1)
        success: bool = parentItem.insertChildren(position, rows, 1)
        self.endInsertRows()

        return success

    def removeRows(self,
                   position: int,
                   rows: int,
                   parent: QModelIndex = QModelIndex()) -> bool:
        parentItem: TreeNode = self.getItem(parent)
        if not parentItem:
            return False

        self.beginRemoveRows(parent, position, position + rows - 1)
        success: bool = parentItem.removeChildren(position, rows)
        self.endRemoveRows()

        return success

    @Slot(TreeNode)
    def addTopLevelItem(self, node: TreeNode):
        self.addItem(self._rootItem, node)

    @Slot(TreeNode, TreeNode)
    def addItem(self, parent: TreeNode, child: TreeNode):
        if not parent or not child:
            return
        self.layoutAboutToBeChanged.emit()

        if child.parentItem():
            parentIndex = self.createIndex(child.parentItem().row(), 0,
                                           child.parentItem())
            self.beginRemoveRows(parentIndex,
                                 child.parentItem().childCount() - 1,
                                 child.parentItem().childCount())
            child.parentItem().removeNode(child)
            self.endRemoveRows()

        parentIndex = self.createIndex(parent.row(), 0, parent)
        self.beginInsertRows(parentIndex, max(parent.childCount() - 1, 0),
                             max(parent.childCount() - 1, 0))
        parent.appendNode(child)
        self.endInsertRows()

        self.layoutChanged.emit()

    @Slot(TreeNode)
    def removeItem(self, item: TreeNode):
        if not item:
            return

        self.layoutAboutToBeChanged.emit()

        if item.parentItem():
            self.beginRemoveRows(QModelIndex(),
                                 item.parentItem().childCount() - 1,
                                 item.parentItem().childCount())
            item.parentItem().removeNode(item)
            self.endRemoveRows()

        self.layoutChanged.emit()

    @Slot()
    def clear(self):
        self.layoutAboutToBeChanged.emit()
        self.beginResetModel()
        self._rootItem.clear()
        self.endResetModel()
        self.layoutChanged.emit()

    def rootItems(self):
        return self._rootItem.childNodes

    def _repr_recursion(self, item: TreeNode, indent: int = 0) -> str:
        result = " " * indent + repr(item) + "\n"
        for child in item.childNodes:
            result += self._repr_recursion(child, indent + 2)
        return result

    def __repr__(self) -> str:
        return self._repr_recursion(self._rootItem)

    def _appendNode(self, node):
        self._rootItem.appendNode(node)

    def _child(self, n):
        return self._rootItem.child(n)

    def _childCount(self):
        return self._rootItem.childCount()

    topItems = ListProperty(TreeNode, _appendNode, _child, clear, _childCount)
