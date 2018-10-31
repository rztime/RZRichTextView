# RZFileManager


可以直接添加

```objc
pod 'RZFileManager'
```

* 文件下载管理 RZFileDownloadManager

* 1.初始化下载 

```objc
- (instancetype)initWithDownloadURL:(NSString *)url progress:(RZDownloadProgress)progress complete:(RZDownloadComplete)complete;
```

* 2.获取所有的已经存在过的下载的数据

```objc
/**
查询得到数据库中已经存在的下载的内容

@return <#return value description#>
*/
+ (NSArray <RZFileDownloadManager *> *)rz_queryAllDownloadFiles;
```

* 3.如果当中有未完成的下载，则可以直接调用

```objc 
/**
下载
*/
- (void)downLoad;

```

重新下载


此时若想得到进度以及完成后的回调
可以使用属性

```objc
@property (nonatomic, copy) RZDownloadProgress preogress; // 进度

@property (nonatomic, copy) RZDownloadComplete downloadComplete; // 完成之后的回调

```

* 删除数据库数据和文件

```objc

/**
删除，从文件夹中删除文件，并删除数据库的数据

@return <#return value description#>
*/
- (BOOL)deleteFromCache;
```

