import router from '@ohos.router';
import { CommonConstants } from '../constants/CommonConstants';
import { RecordItem } from '../model/RecordItem';
import { RecordService } from '../service/RecordService';

@Entry
@Component
struct Index {
  @State totalIncome: number = 0;
  @State totalExpense: number = 0;
  @State balance: number = 0;
  @State recentRecords: RecordItem[] = [];
  @State selectedTab: string = 'overview';
  @State incomeByCategory: Map<string, number> = new Map();
  @State expenseByCategory: Map<string, number> = new Map();
  @State isDataLoaded: boolean = false;
  private recordService: RecordService = RecordService.getInstance();

  aboutToAppear() {
    // 异步等待数据加载完成
    this.loadDataAsync();
  }
  
  onPageShow() {
    // 每次页面显示时都刷新数据
    console.log('Index.ets onPageShow called');
    this.loadDataAsync();
  }
  
  // 异步加载数据，确保RecordService完成初始化
  async loadDataAsync() {
    try {
      console.log('Index.ets loadDataAsync called');
      // 确保RecordService已经完成初始化
      await this.recordService.waitForInitialization();
      console.log('RecordService initialized, calling loadData');
      this.loadData();
      this.isDataLoaded = true;
    } catch (error) {
      console.error('Failed to load data asynchronously:', error);
      this.isDataLoaded = true; // 即使失败也要标记为已加载，避免一直等待
    }
  }

  loadData() {
    console.log('Index.ets loadData called');
    
    // 重新获取所有记录
    const allRecords = this.recordService.getAllRecords();
    console.log('All records count:', allRecords.length);
    console.log('All records:', JSON.stringify(allRecords));
    
    this.recentRecords = this.recordService.getRecentRecords(5);
    this.totalIncome = this.recordService.getTotalIncome();
    this.totalExpense = this.recordService.getTotalExpense();
    this.balance = this.totalIncome - this.totalExpense;
    
    // 检查RecordService返回的分类统计数据
    const incomeData = this.recordService.getIncomeByCategory();
    console.log('Income by category from service:', JSON.stringify(Array.from(incomeData.entries())));
    
    const expenseData = this.recordService.getExpenseByCategory();
    console.log('Expense by category from service:', JSON.stringify(Array.from(expenseData.entries())));
    
    // 创建新的Map对象触发UI重渲染
    const newIncomeMap = new Map<string, number>();
    incomeData.forEach((value, key) => {
      console.log('Adding income category:', key, 'amount:', value);
      newIncomeMap.set(key, value);
    });
    console.log('New income map:', JSON.stringify(Array.from(newIncomeMap.entries())));
    this.incomeByCategory = newIncomeMap;
    
    const newExpenseMap = new Map<string, number>();
    expenseData.forEach((value, key) => {
      console.log('Adding expense category:', key, 'amount:', value);
      newExpenseMap.set(key, value);
    });
    console.log('New expense map:', JSON.stringify(Array.from(newExpenseMap.entries())));
    this.expenseByCategory = newExpenseMap;
    
    console.log('loadData completed');
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('个人记账本')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%');
      }
      .height(60)
      .backgroundColor('#007AFF')
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16, right: 16 });
      
      // 标签页切换
      Row() {
        Column() {
          Text('概览')
            .fontSize(14)
            .fontWeight(this.selectedTab === 'overview' ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.selectedTab === 'overview' ? '#007AFF' : '#666666');
        }
        .width(80)
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.selectedTab = 'overview';
        });
        Column() {
          Text('记录')
            .fontSize(14)
            .fontWeight(this.selectedTab === 'records' ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.selectedTab === 'records' ? '#007AFF' : '#666666');
        }
        .width(80)
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.selectedTab = 'records';
        });
        Column() {
          Text('统计')
            .fontSize(14)
            .fontWeight(this.selectedTab === 'statistics' ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.selectedTab === 'statistics' ? '#007AFF' : '#666666');
        }
        .width(80)
        .height('100%')
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.selectedTab = 'statistics';
        });
      }
      .height(50)
      .backgroundColor('#ffffff')
      .justifyContent(FlexAlign.SpaceAround)
      .padding({ top: 10, bottom: 10 });
      
      // 内容区域
      Column() {
        if (this.selectedTab === 'overview') {
          Column() {
            // 收支概览卡片
            Column() {
              Column() {
                Text('账户余额')
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ bottom: 8 });
                Text(`¥${this.balance.toFixed(2)}`)
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#007AFF')
                  .margin({ bottom: 16 });
                
                Row() {
                  Column() {
                    Text('收入')
                      .fontSize(14)
                      .fontColor('#666666');
                    Text(`¥${this.totalIncome.toFixed(2)}`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#34C759');
                  }
                  .flexGrow(1);
                  
                  Divider()
                    .height(40)
                    .margin({ left: 16, right: 16 });
                  
                  Column() {
                    Text('支出')
                      .fontSize(14)
                      .fontColor('#666666');
                    Text(`¥${this.totalExpense.toFixed(2)}`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FF3B30');
                  }
                  .flexGrow(1);
                }
              }
              .padding(16)
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .shadow({
              radius: 4,
              color: '#00000014',
              offsetX: 0,
              offsetY: 2
            });
          }
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .shadow({
              radius: 4,
              color: '#00000014',
              offsetX: 0,
              offsetY: 2
            })
            .margin({ bottom: 16 });
            
            // 最近记录
            Text('最近记录')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12 })
              .alignSelf(ItemAlign.Start);
            
            List() {
              ForEach(this.recentRecords, (item: RecordItem) => {
                ListItem() {
                  Row() {
                    Column() {
                      Text(item.category)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold);
                      Text(item.date)
                      .fontSize(12)
                      .fontColor('#999999');
                    }
                    .flexGrow(1);
                    
                    Text(`${item.type === 'income' ? '+' : '-'}¥${item.amount.toFixed(2)}`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(item.type === 'income' ? '#34C759' : '#FF3B30');
                    
                    // 编辑按钮
                    Text('编辑')
                      .fontSize(14)
                      .fontColor('#007AFF')
                      .margin({ right: 16 })
                      .onClick(() => {
                        // 跳转到编辑页面
                        router.pushUrl({
                          url: 'pages/AddRecordPage',
                          params: { record: item }
                        });
                      });
                    
                    // 删除按钮
                    Text('删除')
                      .fontSize(14)
                      .fontColor('#FF3B30')
                      .onClick(() => {
                        // 删除记录
                      this.recordService.deleteRecord(item.id);
                      // 刷新数据
                      this.loadData();
                      });
                  }
                  .padding(12)
                  .borderRadius(8)
                  .backgroundColor('#f5f5f5')
                  .margin({ bottom: 8 });
                }
              }, (item: RecordItem) => item.id.toString());
            }
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .padding(8);
          }
        } else if (this.selectedTab === 'records') {
          Column() {
            Text('交易记录')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12 })
              .alignSelf(ItemAlign.Start);
            
            List() {
              ForEach(this.recentRecords, (item: RecordItem) => {
                ListItem() {
                  Row() {
                    Column() {
                      Text(item.category)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold);
                      Text(item.date)
                      .fontSize(12)
                      .fontColor('#999999');
                    }
                    .flexGrow(1);
                    
                    Text(`${item.type === 'income' ? '+' : '-'}¥${item.amount.toFixed(2)}`)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(item.type === 'income' ? '#34C759' : '#FF3B30');
                  }
                  .padding(12)
                  .borderRadius(8)
                  .backgroundColor('#f5f5f5')
                  .margin({ bottom: 8 });
                }
              }, (item: RecordItem) => item.id.toString());
            }
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .padding(8);
          }
        } else if (this.selectedTab === 'statistics') {
          Column() {
            Text('收支统计')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })
              .width('100%')
              .textAlign(TextAlign.Center);
            
            // 收支统计卡片
            Column() {
              Text('本月收入分类')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 16 });
                
              // 收入分类统计
            ForEach(Array.from(this.incomeByCategory.entries()), (entry: [string, number]) => {
              Row() {
                Text(entry[0])
                  .fontSize(14)
                  .fontColor('#666666')
                  .flexGrow(1);
                
                Text(`¥${entry[1].toFixed(2)}`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#34C759');
              }
              .padding(8)
              .margin({ bottom: 8 });
            }, (entry: [string, number]) => entry[0]);
            
            // 如果没有收入记录，显示默认信息
            if (this.incomeByCategory.size === 0) {
                Text('暂无收入记录')
                  .fontSize(14)
                  .fontColor('#999999')
                  .textAlign(TextAlign.Center)
                  .padding(16);
              }
            }
            .padding(16)
            .margin({ bottom: 16 })
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .shadow({
              radius: 4,
              color: '#00000014',
              offsetX: 0,
              offsetY: 2
            });
            
            // 支出统计卡片
            Column() {
              Text('本月支出分类')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .margin({ bottom: 16 });
                
              // 支出分类统计
            ForEach(Array.from(this.expenseByCategory.entries()), (entry: [string, number]) => {
              Row() {
                Text(entry[0])
                  .fontSize(14)
                  .fontColor('#666666')
                  .flexGrow(1);
                
                Text(`¥${entry[1].toFixed(2)}`)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FF3B30');
              }
              .padding(8)
              .margin({ bottom: 8 });
            }, (entry: [string, number]) => entry[0]);
            
            // 如果没有支出记录，显示默认信息
            if (this.expenseByCategory.size === 0) {
                Text('暂无支出记录')
                  .fontSize(14)
                  .fontColor('#999999')
                  .textAlign(TextAlign.Center)
                  .padding(16);
              }
            }
            .padding(16)
            .backgroundColor('#ffffff')
            .borderRadius(12)
            .shadow({
              radius: 4,
              color: '#00000014',
              offsetX: 0,
              offsetY: 2
            });
          }
        }
      }
      .flexGrow(1)
      .width('100%')
      .padding(16);
      
      // 底部添加按钮
      Row() {
        Button('+ 记一笔')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#007AFF')
          .width('100%')
          .height(50)
          .borderRadius(25)
          .margin({ bottom: 16 })
          .onClick(() => {
            // 跳转到添加记录页面
            router.pushUrl({ url: 'pages/AddRecordPage' });
          });
      }
      .padding({ left: 16, right: 16, bottom: 16 });
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#f5f5f5');
  }
}