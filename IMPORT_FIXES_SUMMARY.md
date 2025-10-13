# Import Fixes Summary

## Root Cause
The error `"schemas" is unknown import symbol basedpyright(reportAttributeAccessIssue)` was occurring because the directories were missing `__init__.py` files, which are required for Python to recognize directories as importable packages.

Specifically, the following directories were missing `__init__.py` files:
- `app/` 
- `app/schemas/`
- `app/models/`
- `app/routes/`

## Solution Implemented
Created the missing `__init__.py` files with appropriate content:

1. `app/__init__.py` - Empty file to make app a package
2. `app/schemas/__init__.py` - Exports all schema classes
3. `app/models/__init__.py` - Exports all model classes
4. `app/routes/__init__.py` - Empty file to make routes a package

## Files Created
- `backend/sales-api/app/__init__.py`
- `backend/sales-api/app/schemas/__init__.py`
- `backend/sales-api/app/models/__init__.py`
- `backend/sales-api/app/routes/__init__.py`

## Verification
After creating these files, the import statements in the following files now work correctly:
- `app/routes/auth.py`
- `app/routes/customers.py`
- `app/main.py`

The Pyright error should now be resolved as the directories are properly recognized as Python packages.