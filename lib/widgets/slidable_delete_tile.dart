import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 全局状态管理，确保同时只有一个删除按钮打开
class SlidableController {
  static SlidableController? _instance;

  static SlidableController get instance {
    _instance ??= SlidableController._();
    return _instance!;
  }

  SlidableController._();

  // 当前打开的项目
  _SlidableDeleteTileState? _currentOpenTile;

  // 设置当前打开的项目
  void setCurrentOpenTile(_SlidableDeleteTileState tile) {
    // 如果已经有其他打开的项目，先关闭它
    if (_currentOpenTile != null && _currentOpenTile != tile) {
      _currentOpenTile!._resetPosition();
    }
    _currentOpenTile = tile;
  }

  // 关闭当前打开的项目
  void closeCurrentTile() {
    _currentOpenTile?._resetPosition();
    _currentOpenTile = null;
  }
}

class SlidableDeleteTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Key? itemKey;

  const SlidableDeleteTile({
    super.key,
    required this.child,
    required this.onDelete,
    required this.onTap,
    required this.onLongPress,
    this.itemKey,
  });

  @override
  State<SlidableDeleteTile> createState() => _SlidableDeleteTileState();
}

class _SlidableDeleteTileState extends State<SlidableDeleteTile> {
  // 滑动位置
  double _dragExtent = 0.0;
  // 是否已经打开删除按钮
  bool _isOpen = false;
  // 删除按钮宽度
  final double _deleteButtonWidth = 80.0;
  // 拖动阈值，超过这个比例会自动打开
  final double _openThreshold = 0.3;

  @override
  void dispose() {
    // 如果当前打开的是这个项目，清除引用
    if (SlidableController.instance._currentOpenTile == this) {
      SlidableController.instance._currentOpenTile = null;
    }
    super.dispose();
  }

  // 重置滑动状态
  void _resetPosition() {
    if (!mounted) return;
    setState(() {
      _isOpen = false;
      _dragExtent = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 构建删除按钮 - 拟物化垃圾桶图标
    final deleteButton = Container(
      width: _deleteButtonWidth,
      height: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            // 振动反馈
            HapticFeedback.mediumImpact();
            // 执行删除回调
            widget.onDelete();
            // 重置状态
            _resetPosition();
            // 清除当前打开的引用
            SlidableController.instance._currentOpenTile = null;
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade600,
                size: 26,
              ),
            ),
          ),
        ),
      ),
    );

    return Stack(
      children: [
        // 滑动背景（删除按钮区域）
        Positioned.fill(
          child: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: (_dragExtent.abs() / _deleteButtonWidth).clamp(0.0, 1.0),
              child: deleteButton,
            ),
          ),
        ),

        // 可滑动的内容 - 使用GestureDetector实现水平滑动
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) {
            // 开始拖动，关闭其他打开的项目
            SlidableController.instance.closeCurrentTile();
          },
          onHorizontalDragUpdate: (details) {
            setState(() {
              // 更新滑动位置
              _dragExtent += details.delta.dx;
              // 限制范围
              _dragExtent = _dragExtent.clamp(-_deleteButtonWidth, 0.0);
            });
          },
          onHorizontalDragEnd: (details) {
            // 根据滑动速度和距离决定是否打开删除按钮
            final velocity = details.velocity.pixelsPerSecond.dx;

            // 向右滑动速度快，或者已经接近原位，则关闭
            if (velocity > 300 ||
                _dragExtent > -_deleteButtonWidth * _openThreshold) {
              _resetPosition();
              SlidableController.instance._currentOpenTile = null;
            }
            // 向左滑动速度快，或者已经接近全开，则打开
            else if (velocity < -300 ||
                _dragExtent.abs() >= _deleteButtonWidth * _openThreshold) {
              // 打开删除按钮
              setState(() {
                _isOpen = true;
                _dragExtent = -_deleteButtonWidth;
              });
              // 记录当前打开的项目
              SlidableController.instance.setCurrentOpenTile(this);
              // 振动反馈
              HapticFeedback.lightImpact();
            }
            // 其他情况，保持原样
            else if (_isOpen) {
              setState(() {
                _dragExtent = -_deleteButtonWidth;
              });
            } else {
              _resetPosition();
            }
          },
          onTap:
              _isOpen
                  ? () {
                    // 如果删除按钮是打开的，点击内容区域关闭它
                    _resetPosition();
                    SlidableController.instance._currentOpenTile = null;
                  }
                  : widget.onTap,
          onLongPress: _isOpen ? null : widget.onLongPress,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(_dragExtent, 0.0, 0.0),
            child: widget.child,
          ),
        ),

        // 添加一个额外的点击处理区域，确保删除按钮可点击
        if (_isOpen)
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            width: _deleteButtonWidth,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                // 振动反馈
                HapticFeedback.mediumImpact();
                // 执行删除回调
                widget.onDelete();
                // 重置状态
                _resetPosition();
                // 清除当前打开的引用
                SlidableController.instance._currentOpenTile = null;
              },
              child: Container(color: Colors.transparent),
            ),
          ),
      ],
    );
  }
}
