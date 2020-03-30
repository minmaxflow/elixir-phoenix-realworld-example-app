#### 检查是否utf8mb4
```
mysql> SELECT default_character_set_name FROM information_schema.SCHEMATA
    -> WHERE schema_name = "conduit_dev";
+----------------------------+
| default_character_set_name |
+----------------------------+
| utf8mb4                    |
+----------------------------+
1 row in set (0.00 sec)
```

#### 测试单个test case 

`mix test test/conduit/blog_test.exs:77`