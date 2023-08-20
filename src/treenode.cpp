#include "treenode.h"

QQmlListProperty<TreeNode> TreeNode::childNodes() {
    return { this,
            this,
            &TreeNode::appendChild,
            &TreeNode::childCount,
            &TreeNode::child,
            &TreeNode::clear };
}

TreeNode::TreeNode(TreeNode *parent) : QObject{ parent }, itemData_() {}

TreeNode::TreeNode(const QVariant& data, TreeNode* parent) : QObject{ parent }, itemData_(data) {}

TreeNode::~TreeNode() { qDeleteAll(childNodes_); }

void TreeNode::appendChild(TreeNode* item) {
    if (item && !childNodes_.contains(item)) {
        item->setParent(this);
        childNodes_.append(item);
    }
}

void TreeNode::removeChild(TreeNode* item) {
    if (item)
        childNodes_.removeAll(item);
}

TreeNode *TreeNode::parentItem() const { return qobject_cast<TreeNode*>(parent()); }

TreeNode* TreeNode::child(qsizetype row) { return childNodes_.value(row); }

void TreeNode::appendChild(QQmlListProperty<TreeNode>* list, TreeNode* node) {
    reinterpret_cast<TreeNode*>(list->data)->appendChild(node);
}
qsizetype TreeNode::childCount(QQmlListProperty<TreeNode>* list) {
    return reinterpret_cast<TreeNode*>(list->data)->childCount();
}
TreeNode* TreeNode::child(QQmlListProperty<TreeNode>* list, qsizetype row) {
    return reinterpret_cast<TreeNode*>(list->data)->child(row);
}
void TreeNode::clear(QQmlListProperty<TreeNode>* list) {
    reinterpret_cast<TreeNode*>(list->data)->clear();
}

qsizetype TreeNode::childCount() const { return childNodes_.count(); }

const QVariant& TreeNode::data() const { return itemData_; }

void TreeNode::setData(const QVariant& data) {
    itemData_ = data;
    emit dataChanged(data);
}

bool TreeNode::isLeaf() const { return childNodes_.isEmpty(); }

int TreeNode::depth() const {
    int depth = 0;
    for (TreeNode* anchestor = parentItem(); anchestor; anchestor = anchestor->parentItem())
        ++depth;
    return depth;
}

void TreeNode::clear() {
    itemData_.clear();
    childNodes_.clear();
}

int TreeNode::row() const {
    if (parentItem())
        return parentItem()->childNodes_.indexOf(const_cast<TreeNode*>(this));
    return 0;
}
