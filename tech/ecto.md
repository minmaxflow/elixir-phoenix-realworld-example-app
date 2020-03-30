#### `validate_required` support partial update

https://hexdocs.pm/ecto/Ecto.Changeset.html#validate_required/3

```
If a field is given to validate_required/3 but it has not been passed as parameter during cast/3 (i.e. it has not been changed), then validate_required/3 will check for its current value in the data. If the data contains an non-empty value for the field, then no error is added. This allows developers to use validate_required/3 to perform partial updates. For example, on insert all fields would be required, because their default values on the data are all nil, but on update, if you don't want to change a field that has been previously set, you are not required to pass it as a paramater, since validate_required/3 won't add an error for missing changes as long as the value in the data given to the changeset is not empty.
```

#### `unique_constraint` on primary key

https://elixirforum.com/t/ecto-unique-constraint-for-primary-key/3288

#### `belongs_to` , `has_many` and `many_to_many`

https://hexdocs.pm/ecto/Ecto.Schema.html#belongs_to/3

```
:foreign_key - Sets the foreign key field name, defaults to the name of the association suffixed by _id. For example, belongs_to :company will define foreign key of :company_id. The associated has_one or has_many field in the other schema should also have its :foreign_key option set with the same value.
```

https://hexdocs.pm/ecto/Ecto.Schema.html#has_many/3

```
:foreign_key - Sets the foreign key, this should map to a field on the other schema, defaults to the underscored name of the current schema suffixed by _id
```

https://hexdocs.pm/ecto/Ecto.Schema.html#many_to_many/3
```
:on_replace - The action taken on associations when the record is replaced when casting or manipulating parent changeset. May be :raise (default), :mark_as_invalid, or :delete. :delete will only remove data from the join source, never the associated records. See Ecto.Changeset's section on related data for more info.

```

#### Titled URL Slugs in Phoenix

https://hashrocket.com/blog/posts/titled-url-slugs-in-phoenix
https://hexdocs.pm/phoenix/Phoenix.Router.html#resources/4

#### association , many to many and upsert 

http://blog.plataformatec.com.br/2015/08/working-with-ecto-associations-and-embeds/
http://blog.plataformatec.com.br/2016/12/many-to-many-and-upserts/

#### query compose and preloads

https://www.amberbit.com/blog/2019/4/16/composing-ecto-queries-filters-and-preloads/

#### mysql group by 

https://stackoverflow.com/questions/33784786/how-to-check-if-value-exists-in-each-group-after-group-by
https://dev.mysql.com/doc/refman/5.7/en/group-by-functional-dependence.html
https://gabi.dev/2016/03/03/group-by-are-you-sure-you-know-it/ 

#### `select_merge`

https://medium.com/flatiron-labs/til-how-to-select-merge-with-ecto-query-679d03204b9d
