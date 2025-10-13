from django.urls import path
from . import views

urlpatterns = [
    path('employees/', views.employees_list, name='employees_list'),
    path('employees/<int:employee_id>/', views.employee_detail, name='employee_detail'),
    path('departments/', views.departments_list, name='departments_list'),
]