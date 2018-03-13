# Convert a Python Enum to JSON

**A trivial way to make a Python Enum which is based on string tokens 
JSON-serializable is to inherit both str and Enum. 
Look at the example below for some pointers.**


## How? 

I've prepared a quick demo below. 
Once I figured it out I laughed at myself for not seeing it earlier.

**pet.py**[[code]](https://github.com/Hultner/hultner.github.io/blob/master/quickbits/code/pet.py)
```python
from enum import Enum

class PetType(str, Enum):
    CAT: str = "cat"
    DOG: str = "dog"
```


Let's test it out in our interpreter
```python
>>> import json
>>> import pet
>>> json.dumps([pet.PetType.CAT, pet.PetType.DOG])
'["cat", "dog"]'
```

It's really that easy!  
No need for a custom JSONEncoder, str is already serializable.
The built in [IntEnum](https://github.com/python/cpython/blob/3.6/Lib/enum.py#L639) 
works the same way, in fact that's how I figured it out.


## Taking it further

This applies for other classes as well. E.g. let a class inherit dict to gain 
it's properties; including JSON serialization with the default encoder.   


