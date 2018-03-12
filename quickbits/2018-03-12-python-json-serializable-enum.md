# [WIP] Python Enum to python 

A trivial way to make a Python Enum based on string tokens JSON-serializable, inherit both str and Enum i.e.

```python
class OurFlag(str, Enum):
    …
```

No need for a custom JSONEncoder as the str primitive class is already serializable, like the built in IntEnum 
