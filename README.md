# DTBlockKVO

**Usage**


**Add an observer**


```
	NSString * token = [person dt_observeForKey:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld  handle:^(NSObject *obj, NSDictionary<NSKeyValueChangeKey,id> *change) {
            NSLog(@"observe value change %@",change);
    }];
```

**Remove Observer**

```
	[person dt_removeObserverWithToken:token];
```