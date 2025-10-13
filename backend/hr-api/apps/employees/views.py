from django.shortcuts import render
from django.http import JsonResponse  # pyright: ignore[reportMissingImports]
from django.views.decorators.csrf import csrf_exempt
import json

@csrf_exempt
def employees_list(request):
    if request.method == 'GET':
        # Return a list of employees
        employees = [
            {'id': 1, 'first_name': 'John', 'last_name': 'Doe', 'email': 'john.doe@company.com', 'position': 'Developer'},
            {'id': 2, 'first_name': 'Jane', 'last_name': 'Smith', 'email': 'jane.smith@company.com', 'position': 'Designer'},
        ]
        return JsonResponse({'employees': employees})
    
    elif request.method == 'POST':
        # Create a new employee
        try:
            data = json.loads(request.body)
            # In a real application, you would save to the database
            return JsonResponse({'message': 'Employee created successfully', 'data': data})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)

@csrf_exempt
def employee_detail(request, employee_id):
    if request.method == 'GET':
        # Return employee details
        employee = {
            'id': employee_id,
            'first_name': 'John',
            'last_name': 'Doe',
            'email': 'john.doe@company.com',
            'phone': '+1234567890',
            'position': 'Developer',
            'department': 'Engineering',
            'hire_date': '2025-01-15',
            'employment_status': 'active',
            'salary': 75000.00
        }
        return JsonResponse({'employee': employee})
    
    elif request.method == 'PUT':
        # Update employee
        try:
            data = json.loads(request.body)
            # In a real application, you would update the database
            return JsonResponse({'message': f'Employee {employee_id} updated', 'data': data})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
    
    elif request.method == 'DELETE':
        # Delete employee
        # In a real application, you would delete from the database
        return JsonResponse({'message': f'Employee {employee_id} deleted'})

@csrf_exempt
def departments_list(request):
    if request.method == 'GET':
        # Return a list of departments
        departments = [
            {'id': 1, 'name': 'Engineering', 'description': 'Software development and engineering'},
            {'id': 2, 'name': 'Marketing', 'description': 'Marketing and promotions'},
        ]
        return JsonResponse({'departments': departments})