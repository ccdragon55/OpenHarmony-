import { CommonConstants } from '../constants/CommonConstants';
import { RecordItem } from '../model/RecordItem';
import { RecordService } from '../service/RecordService';
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';

interface GeneratedTypeLiteralInterface_1 {
  record?: RecordItem;
}

@Entry
@Component
struct AddRecordPage {
  @State recordType: string = CommonConstants.RECORD_TYPE_EXPENSE;
  @State selectedCategory: string = CommonConstants.CATEGORIES_EXPENSE[0];
  @State amount: string = '';
  @State description: string = '';
  @State isEditMode: boolean = false;
  @State editingRecord: RecordItem | null = null;
  private recordService: RecordService = RecordService.getInstance();
  
  // 获取当前选中类型对应的分类列表
  get currentCategories(): string[] {
    return this.recordType === CommonConstants.RECORD_TYPE_INCOME 
      ? CommonConstants.CATEGORIES_INCOME 
      : CommonConstants.CATEGORIES_EXPENSE;
  }
  
  // 页面加载时调用，处理编辑记录数据
  aboutToAppear() {
    // 检查是否有传递过来的记录数据（编辑模式）
    const params: object = router.getParams() as object;
    if (params) {
      const recordObj = params as GeneratedTypeLiteralInterface_1;
      if (recordObj.record) {
        const record = recordObj.record;
        this.isEditMode = true;
        this.editingRecord = record;
        this.recordType = record.type;
        this.selectedCategory = record.category;
        this.amount = record.amount.toString();
        this.description = record.description || '';
      }
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('返回')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#007AFF')
          .width(80)
          .height(40)
          .borderRadius(20)
          .onClick(() => {
            router.back();
          });
        
        Text('记一笔')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
          .width('100%');
      }
      .height(60)
      .alignItems(VerticalAlign.Center)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#ffffff');
      
      // 可滚动内容区域
      Scroll() {
        Column() {
          // 记录类型选择
          Row() {
            Column() {
              Text('支出')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.recordType === CommonConstants.RECORD_TYPE_EXPENSE ? '#007AFF' : '#666666');
            }
            .width(120)
            .height(50)
            .borderRadius(25)
            .backgroundColor(this.recordType === CommonConstants.RECORD_TYPE_EXPENSE ? '#e3f2fd' : '#e0e0e0')
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.recordType = CommonConstants.RECORD_TYPE_EXPENSE;
              this.selectedCategory = CommonConstants.CATEGORIES_EXPENSE[0];
            });
            
            Column() {
              Text('收入')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.recordType === CommonConstants.RECORD_TYPE_INCOME ? '#007AFF' : '#666666');
            }
            .width(120)
            .height(50)
            .borderRadius(25)
            .backgroundColor(this.recordType === CommonConstants.RECORD_TYPE_INCOME ? '#e3f2fd' : '#e0e0e0')
            .alignItems(HorizontalAlign.Center)
            .justifyContent(FlexAlign.Center)
            .onClick(() => {
              this.recordType = CommonConstants.RECORD_TYPE_INCOME;
              this.selectedCategory = CommonConstants.CATEGORIES_INCOME[0];
            });
          }
          .height(80)
          .justifyContent(FlexAlign.SpaceAround)
          .padding({ left: 16, right: 16 })
          .backgroundColor('#ffffff');
          
          // 金额输入
          Column() {
            Text('金额')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })
              .alignSelf(ItemAlign.Start);
            
            Row() {
              Text('¥')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#666666')
                .margin({ right: 8 });
              
              TextInput({
                text: this.amount,
                placeholder: '0.00'
              })
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .width('100%')
                .textAlign(TextAlign.Start)
                .onChange((value: string) => {
                  this.amount = value;
                });
            }
            .padding({ left: 16, right: 16 });
          }
          .height(100)
          .backgroundColor('#ffffff')
          .padding({ left: 16, right: 16, top: 16 })
          .margin({ top: 12 });
          
          // 分类选择
          Column() {
            Text('分类')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 12 })
              .alignSelf(ItemAlign.Start);
            
            Grid() {
              ForEach((this.recordType === CommonConstants.RECORD_TYPE_INCOME ? CommonConstants.CATEGORIES_INCOME : CommonConstants.CATEGORIES_EXPENSE), (category: string) => {
                GridItem() {
                  Column() {
                    Text(category)
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.selectedCategory === category ? '#007AFF' : '#666666');
                  }
                  .width(80)
                  .height(50)
                  .borderRadius(8)
                  .backgroundColor(this.selectedCategory === category ? '#e3f2fd' : '#ffffff')
                  .borderWidth(this.selectedCategory === category ? 2 : 1)
                  .borderColor(this.selectedCategory === category ? '#007AFF' : '#e0e0e0')
                  .alignItems(HorizontalAlign.Center)
                  .justifyContent(FlexAlign.Center)
                  .onClick(() => {
                    this.selectedCategory = category;
                  });
                }
              }, (category: string) => category);
            }
            .columnsTemplate('1fr 1fr 1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .padding({ left: 8, right: 8 })
            .height(150); // 设置固定高度
          }
          .backgroundColor('#ffffff')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          .margin({ top: 12 });
          
          // 备注输入
          Column() {
            Text('备注')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })
              .alignSelf(ItemAlign.Start);
            
            TextInput({
              text: this.description,
              placeholder: '添加备注（可选）'
            })
              .fontSize(16)
              .height(80)
              .width('100%')
              .backgroundColor('#f5f5f5')
              .borderRadius(8)
              .padding(12)
              .onChange((value: string) => {
                this.description = value;
              });
          }
          .backgroundColor('#ffffff')
          .padding({ left: 16, right: 16, top: 16, bottom: 16 })
          .margin({ top: 12 });
        }
        .width('100%');
      }
      .flexGrow(1); // 占据剩余空间
      
      // 保存按钮（固定在底部）
      Button('保存')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#007AFF')
        .width('100%')
        .height(50)
        .borderRadius(25)
        .margin({ left: 16, right: 16, bottom: 24 }) // 确保边距，防止被底部遮挡
        .onClick(() => {
          // 验证输入
          if (!this.amount || parseFloat(this.amount) <= 0) {
            // 显示错误提示
            promptAction.showToast({
              message: '请输入有效金额',
              duration: 2000
            });
            return;
          }
          
          // 获取当前日期时间
          const today = new Date().toISOString().split('T')[0];
          const now = new Date();
          const time = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;
          
          // 创建或更新记录
          if (this.isEditMode && this.editingRecord) {
            // 更新现有记录
            const updatedRecord = new RecordItem(
              this.recordType,
              this.selectedCategory,
              parseFloat(this.amount),
              this.editingRecord.date, // 保持原日期
              this.editingRecord.time, // 保持原时间
              this.description
            );
            updatedRecord.id = this.editingRecord.id; // 保持原ID
            
            // 更新记录
            this.recordService.updateRecord(updatedRecord);
            
            // 显示成功提示
            promptAction.showToast({
              message: '记录更新成功',
              duration: 2000
            });
          } else {
            // 创建新记录
            const record = new RecordItem(
              this.recordType,
              this.selectedCategory,
              parseFloat(this.amount),
              today,
              time,
              this.description
            );
            
            // 保存记录
            this.recordService.addRecord(record);
            
            // 显示成功提示
            promptAction.showToast({
              message: '记录添加成功',
              duration: 2000
            });
          }
          
          // 返回主页面
          router.back();
        });
    }
    .height('100%')
    .width('100%')
    .backgroundColor('#f5f5f5');
  }
}