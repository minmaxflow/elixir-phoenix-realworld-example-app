#### Errors and Status Codes

If a request fails any validations, expect a 422 and errors in the following format:

```JSON
{
  "errors":{
    "body": [
      "can't be empty"
    ]
  }
}
```

#### Other status codes:

401 for Unauthorized requests, when a request requires authentication but it isn't provided

403 for Forbidden requests, when a request may be valid but the user doesn't have permissions to perform the action

404 for Not found requests, when a resource can't be found to fulfill the request

#### Phoenix对应的错误处理

数据校验错误，从Context层会返回`{:error, changeset}`, 在`FallbackController`进行处理

对于资源不存在，在Context层会基于`Repo.get!`或者`Repo.get_by!`,抛出`Ecto.NoResultsError`,在`ErrorView`中进行处理
还有一个可能是从Context层返回`{:error, :not_found}`, 在`FallbackController`进行处理

认证失败, 通过`{:error, :unauthorized}`在`FallbackController`进行处理

授权失败, 通过`{:error, :forbidden}`在`FallbackController`进行处理(以现在的情况来说，应该没有这个错误)

可以通过配置`config/dev.exs`里面`debug_errors: false`, 在开发模式下显示json返回