from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.views import View
import json

@csrf_exempt
def accounts_list(request):
    if request.method == 'GET':
        # Return a list of accounts
        accounts = [
            {'id': 1, 'name': 'Cash', 'code': '1000', 'type': 'asset'},
            {'id': 2, 'name': 'Accounts Receivable', 'code': '1100', 'type': 'asset'},
            {'id': 3, 'name': 'Revenue', 'code': '4000', 'type': 'revenue'},
        ]
        return JsonResponse({'accounts': accounts})
    
    elif request.method == 'POST':
        # Create a new account
        try:
            data = json.loads(request.body)
            # In a real application, you would save to the database
            return JsonResponse({'message': 'Account created successfully', 'data': data})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)

@csrf_exempt
def account_detail(request, account_id):
    if request.method == 'GET':
        # Return account details
        account = {
            'id': account_id,
            'name': 'Sample Account',
            'code': '1000',
            'type': 'asset',
            'description': 'Sample account description'
        }
        return JsonResponse({'account': account})
    
    elif request.method == 'PUT':
        # Update account
        try:
            data = json.loads(request.body)
            # In a real application, you would update the database
            return JsonResponse({'message': f'Account {account_id} updated', 'data': data})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
    
    elif request.method == 'DELETE':
        # Delete account
        # In a real application, you would delete from the database
        return JsonResponse({'message': f'Account {account_id} deleted'})

@csrf_exempt
def transactions_list(request):
    if request.method == 'GET':
        # Return a list of transactions
        transactions = [
            {'id': 1, 'account_id': 1, 'type': 'debit', 'amount': 1000.00, 'description': 'Sample transaction'},
            {'id': 2, 'account_id': 3, 'type': 'credit', 'amount': 1000.00, 'description': 'Sample transaction'},
        ]
        return JsonResponse({'transactions': transactions})
    
    elif request.method == 'POST':
        # Create a new transaction
        try:
            data = json.loads(request.body)
            # In a real application, you would save to the database
            return JsonResponse({'message': 'Transaction created successfully', 'data': data})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)