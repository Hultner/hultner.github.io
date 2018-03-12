# [WIP] Python Enum to python 

A trivial way to make a Python Enum based on string tokens JSON-serializable 
is to inherit both str and Enum. Look at the example below for some pointers.

**pet.py**
```python
from enum import Enum

class PetType(str, Enum):
    CAT: str = "cat"
    DOG: str = "dog"
```


Let's test it out in our interpeter
```python
>>> import json
>>> import pet
>>> json.dumps([pet.PetType.CAT, pet.PetType.DOG])
'["cat", "dog"]'
```

Works as expected.
No need for a custom JSONEncoder, str is already serializable.
The built in [IntEnum](https://github.com/python/cpython/blob/3.6/Lib/enum.py#L639) 
works the same way