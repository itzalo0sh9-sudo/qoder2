from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json

@csrf_exempt
def invoices_list(request):
    if request.method == 'GET':
        # Return a list of invoices
        invoices = [
            {'id': 1, 'invoice_number': 'INV-001', 'customer': 'John Doe', 'amount': 1000.00, 'status': 'sent'},
            {'id': 2, 'invoice_number': 'INV-002', 'customer': 'Jane Smith', 'amount': 2000.00, 'status': 'paid'},
        ]
        return JsonResponse({'invoices': invoices})
    
    elif request.method == 'POST':
        # Create a new invoice
        try:
            data = json.loads(request.body)
            # In a real application, you would save to the database
            return JsonResponse({'message': 'Invoice created successfully', 'data': data})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)

@csrf_exempt
def invoice_detail(request, invoice_id):
    if request.method == 'GET':
        # Return invoice details
        invoice = {
            'id': invoice_id,
            'invoice_number': 'INV-001',
            'customer': 'John Doe',
            'amount': 1000.00,
            'status': 'sent',
            'issued_date': '2025-10-01',
            'due_date': '2025-10-31'
        }
        return JsonResponse({'invoice': invoice})
    
    elif request.method == 'PUT':
        # Update invoice
        try:
            data = json.loads(request.body)
            # In a real application, you would update the database
            return JsonResponse({'message': f'Invoice {invoice_id} updated', 'data': data})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
    
    elif request.method == 'DELETE':
        # Delete invoice
        # In a real application, you would delete from the database
        return JsonResponse({'message': f'Invoice {invoice_id} deleted'})

@csrf_exempt
def payments_list(request):
    if request.method == 'GET':
        # Return a list of payments
        payments = [
            {'id': 1, 'invoice_id': 1, 'amount': 1000.00, 'method': 'credit_card', 'date': '2025-10-01'},
        ]
        return JsonResponse({'payments': payments})
    
    elif request.method == 'POST':
        # Create a new payment
        try:
            data = json.loads(request.body)
            # In a real application, you would save to the database
            return JsonResponse({'message': 'Payment created successfully', 'data': data})
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)