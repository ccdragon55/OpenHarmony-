// 应用常量定义
export class CommonConstants {
  // 记录类型
  static readonly RECORD_TYPE_INCOME = 'income';
  static readonly RECORD_TYPE_EXPENSE = 'expense';
  
  // 分类定义
  static readonly CATEGORIES_INCOME = [
    '工资', '奖金', '投资收益', '其他收入'
  ];
  
  static readonly CATEGORIES_EXPENSE = [
    '餐饮', '交通', '购物', '娱乐', '医疗', '教育', '房租', '水电费', '其他支出'
  ];
  
  // 日期格式
  static readonly DATE_FORMAT = 'YYYY-MM-DD';
  static readonly TIME_FORMAT = 'HH:mm';
  static readonly DATETIME_FORMAT = 'YYYY-MM-DD HH:mm';
  
  // 颜色定义
  static readonly COLOR_INCOME = '#34C759';
  static readonly COLOR_EXPENSE = '#FF3B30';
  static readonly COLOR_BALANCE = '#007AFF';
}