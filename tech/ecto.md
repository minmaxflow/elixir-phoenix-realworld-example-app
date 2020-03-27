#### `validate_required` support partial update

https://hexdocs.pm/ecto/Ecto.Changeset.html#validate_required/3

```
If a field is given to validate_required/3 but it has not been passed as parameter during cast/3 (i.e. it has not been changed), then validate_required/3 will check for its current value in the data. If the data contains an non-empty value for the field, then no error is added. This allows developers to use validate_required/3 to perform partial updates. For example, on insert all fields would be required, because their default values on the data are all nil, but on update, if you don't want to change a field that has been previously set, you are not required to pass it as a paramater, since validate_required/3 won't add an error for missing changes as long as the value in the data given to the changeset is not empty.
```

#### `unique_constraint` on primary key

https://elixirforum.com/t/ecto-unique-constraint-for-primary-key/3288

#### `belongs_to` and `has_many`

https://hexdocs.pm/ecto/Ecto.Schema.html#belongs_to/3

```
:foreign_key - Sets the foreign key field name, defaults to the name of the association suffixed by _id. For example, belongs_to :company will define foreign key of :company_id. The associated has_one or has_many field in the other schema should also have its :foreign_key option set with the same value.
```

https://hexdocs.pm/ecto/Ecto.Schema.html#has_many/3

```
:foreign_key - Sets the foreign key, this should map to a field on the other schema, defaults to the underscored name of the current schema suffixed by _id
```