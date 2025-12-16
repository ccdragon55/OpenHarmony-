import { CommonConstants } from '../constants/CommonConstants';

// 记账记录数据模型
export class RecordItem {
  id: number;
  type: string; // 'income' 或 'expense'
  category: string;
  amount: number;
  date: string;
  time: string;
  description?: string;
  
  constructor(type: string, category: string, amount: number, date: string, time: string, description?: string) {
    this.id = Date.now(); // 使用时间戳作为临时ID
    this.type = type;
    this.category = category;
    this.amount = amount;
    this.date = date;
    this.time = time;
    this.description = description;
  }
  
  // 获取完整的日期时间字符串
  getDateTime(): string {
    return `${this.date} ${this.time}`;
  }
  
  // 判断是否为收入
  isIncome(): boolean {
    return this.type === CommonConstants.RECORD_TYPE_INCOME;
  }
  
  // 判断是否为支出
  isExpense(): boolean {
    return this.type === CommonConstants.RECORD_TYPE_EXPENSE;
  }
}