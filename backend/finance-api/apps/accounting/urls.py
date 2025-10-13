from django.urls import path
from . import views

urlpatterns = [
    path('accounts/', views.accounts_list, name='accounts_list'),
    path('accounts/<int:account_id>/', views.account_detail, name='account_detail'),
    path('transactions/', views.transactions_list, name='transactions_list'),
]