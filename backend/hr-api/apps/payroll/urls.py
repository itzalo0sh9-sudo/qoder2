from django.urls import path
from . import views

urlpatterns = [
    path('periods/', views.payroll_periods_list, name='payroll_periods_list'),
    path('items/', views.payroll_items_list, name='payroll_items_list'),
    path('benefits/', views.benefits_list, name='benefits_list'),
]