# [Hultnér QuickBits](https://hultner.github.io)
## Reflect a PostgreSQL view in Python's SQLAlchemy
**I ran into this problem a while ago**, where I had a simple view created
by joining two tables with a 1:1 relationship in postgresql but SQLAlchemy
didn't like my view.

### Background
The core problem comes from SQLAlchemy being an ORM (object relationship mapper)
made to fit most databases moderately well for most common use cases. However
sometimes it does not fit their model as well. One such case is views and in
particular views in PostgreSQL.

*Why's that?* you might ask. Well here's the thing, to the best of my knowledge
there's as of this date no way to natively reflect a view in SQLAlchemy. Instead
one must use the Table() construct to initiate the view, and herein lies the
foundational problem, see table's in SQLAlchemy requires a primary key to use
as a hash while views in PostgreSQL can't. Clearly a point of conflict.

### A problematic domain model – sample code attached
I've oversimplified the model and view to press on the actual issue and not
steer focus towards unrelated code. In my case we've got a base model for
`Fields` followed by a couple of related models for specialized instances of
these fields. One such is `Template_Field` shown below, this is a mere extension
of the common field type and is never accessed directly but rather through the
view named `Template_Field_View`.

#### Field.psql
```PLpgSQL
CREATE TABLE IF NOT EXISTS quick_bits.Field (
    id             serial PRIMARY KEY,
    order_Index    INTEGER,
    label          TEXT,
    key            VARCHAR(255)
);
```

#### Template_Field.psql
Templates in them self are not interesting for this obstacle and are thus left
out, however I left the relation in Template_Field for illustrative purposes.
```PLpgSQL
CREATE TABLE IF NOT EXISTS quick_bits.Template_Field(
    template    integer REFERENCES quick_bits.Template(id),
    field       integer PRIMARY KEY REFERENCES quick_bits.Field(id),
);
```

#### Template_Field_View.psql
```PLpgSQL
CREATE OR REPLACE VIEW quick_bits.template_field_view AS
  SELECT
    field.id,
    template_field.template,
    field.label,
    field.key,
    field.order_index,
    FROM quick_bits.template_field as template_field
      INNER JOIN quick_bits.field as field
        ON field.id = template_field.field
;
```


### Problems start surfacing
The most naïve approach for me were to just try reflecting the view straight
away as a table with SQLAlchemy in my python code.

```Python
"""

...

"""

def init_table(name):
    return Table(name, meta, autoload=True, schema=config.DB_SCHEMA)

class Field(Base):
    __table__ = init_table('field')

class TemplateField(Base):
    __table__ = init_table('template_field')

class TemplateFieldView(Base):
    __table__ = init_table('template_field_view')

```

Now let's see what happens if we try to read data using this model.
```python

    class TemplateFieldView(Base):
  File "/Users/hultner/Development/quick_bit_test/venv/lib/python3.6/site-packages/sqlalchemy/ext/declarative/api.py", line 64, in __init__
    _as_declarative(cls, classname, cls.__dict__)
  File "/Users/hultner/Development/quick_bit_test/venv/lib/python3.6/site-packages/sqlalchemy/ext/declarative/base.py", line 88, in _as_declarative
    _MapperConfig.setup_mapping(cls, classname, dict_)
  File "/Users/hultner/Development/quick_bit_test/venv/lib/python3.6/site-packages/sqlalchemy/ext/declarative/base.py", line 103, in setup_mapping
    cfg_cls(cls_, classname, dict_)
  File "/Users/hultner/Development/quick_bit_test/venv/lib/python3.6/site-packages/sqlalchemy/ext/declarative/base.py", line 135, in __init__
    self._early_mapping()
  File "/Users/hultner/Development/quick_bit_test/venv/lib/python3.6/site-packages/sqlalchemy/ext/declarative/base.py", line 138, in _early_mapping
    self.map()
  File "/Users/hultner/Development/quick_bit_test/venv/lib/python3.6/site-packages/sqlalchemy/ext/declarative/base.py", line 534, in map
    **self.mapper_args
  File "<string>", line 2, in mapper
  File "/Users/hultner/Development/quick_bit_test/venv/lib/python3.6/site-packages/sqlalchemy/orm/mapper.py", line 677, in __init__
    self._configure_pks()
  File "/Users/hultner/Development/quick_bit_test/venv/lib/python3.6/site-packages/sqlalchemy/orm/mapper.py", line 1277, in _configure_pks
    (self, self.mapped_table.description))
sqlalchemy.exc.ArgumentError: Mapper Mapper|TemplateFieldView|template_field_view could not assemble any primary key columns for mapped table 'template_field_view'

```

The following error does seem daunting but we can quickly see that the problem
lies in mapping a view without primary keys as a table which requires said key.

### First workaround attempt
As we already got a field id which is unique we could try forcing SQLAlchemy
into thinking it's a primary key.

My first approach were something along these lines.
```Python
class TemplateFieldView(Base):
    __table__ = init_table('template_field_view')
    id = Column(Integer, primary_key=True)
```

Let's try it out.
```python
File "/Users/hultner/Development/quick_bit_test/venv/lib/python3.6/site-packages/sqlalchemy/ext/declarative/base.py", line 131, in __init__
    self._setup_table()
File "/Users/hultner/Development/quick_bit_test/venv/lib/python3.6/site-packages/sqlalchemy/ext/declarative/base.py", line 403, in _setup_table
    "specifying __table__" % c.key
sqlalchemy.exc.ArgumentError: Can't add additional column 'id' when specifying __table__
```

Some progress but no cigar. We can now see that the problem is no longer the
primary key but rather that we can't specify new columns like this in a
reflected tables. This is because of the inner workings of SQLAlchemy have
already decided on the table structure and doesn't want to mutate this
representation.

### The solution
So how do we circumvent this dilemma, after some searching I found the
`__mapper_args__` property. We can use this to change the behaviour of columns
in the table/view. Read more at [SQLAchemy Docs]( http://docs.sqlalchemy.org/en/latest/faq/ormconfiguration.html#how-do-i-map-a-table-that-has-no-primary-key).

So now I have the following code.
```python
class TemplateFieldView(Base):
    __table__ = init_table('template_field_view')
    __mapper_args__ = {
        'primary_key':[__table__.c.id]
    }
```

So let's try it out.
```python
>>> get_template_field_from_view(54)
Field(id='54', template='3', order_index='1', label='Name', key='name_data', type='FIRST_NAME')>
```

Success!

There you have it. If anyone got a nicer solution I would love to hear it,
until then I hope this is helpful to you!
