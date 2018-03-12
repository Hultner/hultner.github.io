# [WIP] Python Enum to python 

A trivial way to make a Python Enum based on string tokens JSON-serializable, inherit both str and Enum i.e.

**pet.py**
```python
from enum import Enum

class PetType(str, Enum):
    CAT: str = "cat"
    DOG: str = "dog"
```

No need for a custom JSONEncoder as the str primitive class is already serializable, like the built in IntEnum 

Let's test it out in our interpeter
```python
>>> import json
>>> import pet
>>> json.dumps([pet.PetType.CAT, pet.PetType.DOG])
'["cat", "dog"]'
```

Works as expected.

