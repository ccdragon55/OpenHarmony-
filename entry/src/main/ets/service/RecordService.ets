import { RecordItem } from '../model/RecordItem';
import dataPreferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import { Context } from '@kit.AbilityKit';

// 定义存储记录的接口
export interface StoredRecord {
  id: number;
  type: string;
  category: string;
  amount: number;
  date: string;
  time: string;
  description?: string;
}

// 定义存储键名
const RECORDS_STORAGE_KEY = 'expense_records';

// 记账记录服务类，处理数据的增删改查和统计
  export class RecordService {
    private records: RecordItem[] = [];
    private static instance: RecordService;
    private preferences: dataPreferences.Preferences | null = null;
    private readonly PREFERENCES_NAME = 'expense_records_prefs';
    private readonly RECORDS_KEY = 'records_data';
    private isInitialized: boolean = false;
  private initializationPromise: Promise<void> | null = null;
  private initializeResolve: (() => void) | null = null;
  
  // 私有构造函数，防止外部直接实例化
  private constructor() {
    // 初始化时不加载数据，等待初始化上下文后再加载
    // 创建初始化Promise
    this.initializationPromise = new Promise<void>((resolve) => {
      this.initializeResolve = resolve;
    });
  }
  
  // 初始化方法，需要传入应用上下文
  public async initialize(context: Context): Promise<void> {
    try {
      if (!context) {
        console.error('RecordService initialize: invalid context');
        this.markAsInitialized();
        return;
      }
      
      // 初始化Preferences
      this.preferences = await dataPreferences.getPreferences(context, this.PREFERENCES_NAME);
      console.log('Preferences initialized successfully');
      
      // 加载记录
      await this.loadRecords();
      this.markAsInitialized();
    } catch (error) {
      console.error('RecordService initialize failed:', (error as BusinessError).message);
      this.preferences = null;
      this.markAsInitialized(); // 即使失败也标记为已初始化，避免页面一直等待
    }
  }
  
  // 标记为已初始化
  private markAsInitialized(): void {
    this.isInitialized = true;
    if (this.initializeResolve) {
      this.initializeResolve();
      this.initializeResolve = null;
    }
  }
  
  // 等待初始化完成
  public async waitForInitialization(): Promise<void> {
    if (this.isInitialized) {
      return;
    }
    if (this.initializationPromise) {
      await this.initializationPromise;
    }
  }
  
  // 获取单例实例
  public static getInstance(): RecordService {
    if (!RecordService.instance) {
      RecordService.instance = new RecordService();
    }
    return RecordService.instance;
  }

  
  // 添加记录
  addRecord(record: RecordItem): void {
    console.log('RecordService addRecord called with:', JSON.stringify(record));
    this.records.push(record);
    this.records.sort((a, b) => {
      // 按创建时间降序排序（最新的在前面）
      return b.id - a.id;
    });
    console.log('Records after add:', JSON.stringify(this.records));
    // 异步保存记录
    this.saveRecords().catch((error: BusinessError) => {
      console.error('Failed to save records after add:', error.message);
    });
  }
  
  // 更新记录
  updateRecord(record: RecordItem): void {
    const index = this.records.findIndex(item => item.id === record.id);
    if (index !== -1) {
      this.records[index] = record;
      // 异步保存记录
    this.saveRecords().catch((error: BusinessError) => {
      console.error('Failed to save records after update:', error.message);
    });
    }
  }
  
  // 删除记录
  deleteRecord(id: number): void {
    this.records = this.records.filter(record => record.id !== id);
    // 异步保存记录
    this.saveRecords().catch((error: BusinessError) => {
      console.error('Failed to save records after delete:', error.message);
    });
  }
  
  // 获取所有记录
  getAllRecords(): RecordItem[] {
    // 记录已经在添加时按创建时间排序
    return [...this.records];
  }
  
  // 获取最近的几条记录
  getRecentRecords(limit: number): RecordItem[] {
    return this.getAllRecords().slice(0, limit);
  }
  
  // 获取总收入
  getTotalIncome(): number {
    return this.records
      .filter(record => record.isIncome())
      .reduce((total, record) => total + record.amount, 0);
  }
  
  // 获取总支出
  getTotalExpense(): number {
    return this.records
      .filter(record => record.isExpense())
      .reduce((total, record) => total + record.amount, 0);
  }
  
  // 获取指定日期范围内的记录
  getRecordsByDateRange(startDate: string, endDate: string): RecordItem[] {
    return this.records.filter(record => {
      const recordDate = new Date(record.date);
      const start = new Date(startDate);
      const end = new Date(endDate);
      return recordDate >= start && recordDate <= end;
    });
  }
  
  // 按分类统计支出
  getExpenseByCategory(): Map<string, number> {
    console.log('RecordService getExpenseByCategory called');
    console.log('All records:', JSON.stringify(this.records));
    const categoryMap = new Map<string, number>();
    
    // 使用for循环确保正确处理每一条记录
    for (const record of this.records) {
      if (record.isExpense()) {
        console.log('Processing expense record:', JSON.stringify(record));
        const currentAmount = categoryMap.get(record.category) || 0;
        const newAmount = currentAmount + record.amount;
        console.log(`Category ${record.category}: current=${currentAmount}, adding=${record.amount}, new=${newAmount}`);
        categoryMap.set(record.category, newAmount);
      }
    }
    
    console.log('Expense category map:', JSON.stringify(Array.from(categoryMap.entries())));
    return categoryMap;
  }
  
  // 按分类统计收入
  getIncomeByCategory(): Map<string, number> {
    console.log('RecordService getIncomeByCategory called');
    console.log('All records:', JSON.stringify(this.records));
    const categoryMap = new Map<string, number>();
    
    // 使用for循环确保正确处理每一条记录
    for (const record of this.records) {
      if (record.isIncome()) {
        console.log('Processing income record:', JSON.stringify(record));
        const currentAmount = categoryMap.get(record.category) || 0;
        const newAmount = currentAmount + record.amount;
        console.log(`Category ${record.category}: current=${currentAmount}, adding=${record.amount}, new=${newAmount}`);
        categoryMap.set(record.category, newAmount);
      }
    }
    
    console.log('Income category map:', JSON.stringify(Array.from(categoryMap.entries())));
    return categoryMap;
  }
  
  // 保存记录到Preferences
  private async saveRecords(): Promise<void> {
    try {
      if (!this.preferences) {
        console.error('Preferences not initialized, cannot save records');
        return;
      }
      
      // 转换记录为可存储的对象数组
      const recordsToStore: Array<StoredRecord> = this.records.map(record => ({
        id: record.id,
        type: record.type,
        category: record.category,
        amount: record.amount,
        date: record.date,
        time: record.time,
        description: record.description
      } as StoredRecord));
      
      // 保存到Preferences
      await this.preferences.put(this.RECORDS_KEY, JSON.stringify(recordsToStore));
      await this.preferences.flush();
      
      console.log('Records saved to preferences successfully:', this.records.length);
    } catch (error) {
      console.error('Failed to save records:', (error as BusinessError).message);
    }
  }
  
  // 从Preferences加载记录
  private async loadRecords(): Promise<void> {
    try {
      if (!this.preferences) {
        console.error('Preferences not initialized, cannot load records');
        this.records = [];
        return;
      }
      
      // 从Preferences获取数据
      const recordsJson = await this.preferences.get(this.RECORDS_KEY, '[]');
      
      if (recordsJson && typeof recordsJson === 'string') {
        const recordsData: Array<StoredRecord> = JSON.parse(recordsJson);
        
        // 转换为RecordItem对象
        this.records = recordsData.map((item: StoredRecord) => {
          const record = new RecordItem(item.type, item.category, item.amount, item.date, item.time, item.description);
          record.id = item.id;
          return record;
        });
        
        // 确保记录按创建时间排序
        this.records.sort((a, b) => b.id - a.id);
        
        console.log('Records loaded from preferences successfully:', this.records.length);
      } else {
        this.records = [];
        console.log('No records found in preferences');
      }
    } catch (error) {
      console.error('Failed to load records:', (error as BusinessError).message);
      this.records = [];
    }
  }
}