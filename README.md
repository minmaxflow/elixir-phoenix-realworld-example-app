## Conduit

使用 `Elixir`和`Phoenix`, 实现了[RealWorld API Spec](https://github.com/gothinkster/realworld/tree/master/api) 

###  主要特点
- 接口实现完整
- 有全面的测试覆盖
- 代码简单清晰, 只引入了最必要的依赖库

### 如何使用
- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Start Phoenix endpoint with `mix phx.server`

## 下一步计划

- 和前端联调
    - 前端选用React-Mobx的实现
- 服务端部署
- [采用最佳实践](https://github.com/mirego/elixir-boilerplate)
- 服务端功能增强
    - 生成一些样本数据, data seed 
    - [cursor来分页](https://github.com/bleacherreport/ecto_cursor_pagination)
    - 帖子搜索
    - 图片上传
    - 评论嵌套    
    - OAuth登录
    - 监控
    - GraphQL接口支持
- 前端功能增强
  - React Hook版本
  - SSR 
  - i18n
  - 发帖编辑器, markdown
  - 响应式设计

