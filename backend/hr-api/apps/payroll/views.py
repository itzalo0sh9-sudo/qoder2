from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json

@csrf_exempt
def payroll_periods_list(request):
    if request.method == 'GET':
        # Return a list of payroll periods
        periods = [
            {'id': 1, 'name': 'October 2025', 'type': 'monthly', 'start_date': '2025-10-01', 'end_date': '2025-10-31'},
            {'id': 2, 'name': 'November 2025', 'type': 'monthly', 'start_date': '2025-11-01', 'end_date': '2025-11-30'},
        ]
        return JsonResponse({'payroll_periods': periods})
    
    elif request.method == 'POST':
        # Create a new payroll period
        try:
            data = json.loads(request.body)
            # In a real application, you would save to the database
            return JsonResponse({'message': 'Payroll period created successfully', 'data': data})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)

@csrf_exempt
def payroll_items_list(request):
    if request.method == 'GET':
        # Return a list of payroll items
        items = [
            {'id': 1, 'employee_id': 1, 'period_id': 1, 'gross_salary': 75000.00, 'net_salary': 55000.00, 'paid': True},
            {'id': 2, 'employee_id': 2, 'period_id': 1, 'gross_salary': 65000.00, 'net_salary': 48000.00, 'paid': True},
        ]
        return JsonResponse({'payroll_items': items})
    
    elif request.method == 'POST':
        # Create a new payroll item
        try:
            data = json.loads(request.body)
            # In a real application, you would save to the database
            return JsonResponse({'message': 'Payroll item created successfully', 'data': data})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)

@csrf_exempt
def benefits_list(request):
    if request.method == 'GET':
        # Return a list of benefits
        benefits = [
            {'id': 1, 'employee_id': 1, 'type': 'health_insurance', 'name': 'Health Insurance', 'cost': 500.00},
            {'id': 2, 'employee_id': 2, 'type': 'retirement_plan', 'name': '401k Plan', 'cost': 300.00},
        ]
        return JsonResponse({'benefits': benefits})
    
    elif request.method == 'POST':
        # Create a new benefit
        try:
            data = json.loads(request.body)
            # In a real application, you would save to the database
            return JsonResponse({'message': 'Benefit created successfully', 'data': data})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)