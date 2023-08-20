#include "treemodel.h"

TreeModel::TreeModel(QObject* parent) : QAbstractItemModel(parent) {}

int TreeModel::rowCount(const QModelIndex& parent) const {
    return !parent.isValid() ? rootItem_.childCount() : internalPointer(parent)->childCount();
}

int TreeModel::columnCount(const QModelIndex& /*parent*/) const {
    // This is basically flatten as a list model
    return 1;
}

QModelIndex TreeModel::index(const int row, const int column, const QModelIndex& parent) const {
    if (!hasIndex(row, column, parent)) {
        return {};
    }

    TreeNode* item = parent.isValid() ? internalPointer(parent) : const_cast<TreeNode*>(&rootItem_);

    if (auto child = item->child(row))
        return createIndex(row, column, child);

    return {};
}

QModelIndex TreeModel::parent(const QModelIndex& index) const {
    if (!index.isValid()) {
        return {};
    }

    TreeNode* childItem  = internalPointer(index);
    TreeNode* parentItem = childItem->parentItem();

    if (!parentItem || parentItem == &rootItem_)
        return {};

    return createIndex(parentItem->row(), 0, parentItem);
}

QVariant TreeModel::data(const QModelIndex& index, const int role) const {
    if (!index.isValid() || role != Qt::DisplayRole) {
        return QVariant();
    }

    return internalPointer(index)->data();
}

bool TreeModel::setData(const QModelIndex& index, const QVariant& value, int /*role*/) {
    if (!index.isValid()) {
        return false;
    }

    if (auto item = internalPointer(index)) {
        item->setData(value);
        emit dataChanged(index, index, { Qt::EditRole });
    }

    return false;
}

void TreeModel::addTopLevelItem(TreeNode* child) {
    if (child) {
        addItem(&rootItem_, child);
    }
}

void TreeModel::addItem(TreeNode* parent, TreeNode* child) {
    if (!child || !parent) {
        return;
    }

    emit layoutAboutToBeChanged();

    if (child->parentItem()) {
        beginRemoveRows(QModelIndex(), child->parentItem()->childCount() - 1,
                        child->parentItem()->childCount());
        child->parentItem()->removeChild(child);
        endRemoveRows();
    }

    beginInsertRows(QModelIndex(), qMax(parent->childCount() - 1, 0),
                    qMax(parent->childCount() - 1, 0));
    parent->appendChild(child);
    endInsertRows();

    emit layoutChanged();
}

void TreeModel::removeItem(TreeNode* item) {
    if (!item) {
        return;
    }

    emit layoutAboutToBeChanged();

    if (item->parentItem()) {
        beginRemoveRows(QModelIndex(), item->parentItem()->childCount() - 1,
                        item->parentItem()->childCount());
        item->parentItem()->removeChild(item);
        endRemoveRows();
    }

    emit layoutChanged();
}

TreeNode* TreeModel::rootItem() const { return const_cast<TreeNode*>(&rootItem_); }

void TreeModel::clear() {
    emit layoutAboutToBeChanged();
    beginResetModel();
    rootItem_.clear();
    endResetModel();
    emit layoutChanged();
}

QQmlListProperty<TreeNode> TreeModel::topItems() {
    return rootItem_.childNodes();
}

TreeNode* TreeModel::internalPointer(const QModelIndex& index) const {
    return static_cast<TreeNode*>(index.internalPointer());
}
