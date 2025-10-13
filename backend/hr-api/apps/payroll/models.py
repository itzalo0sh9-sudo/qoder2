from django.db import models
from django.utils import timezone
from apps.employees.models import Employee

class PayrollPeriod(models.Model):
    PERIOD_TYPES = [
        ('weekly', 'Weekly'),
        ('biweekly', 'Bi-weekly'),
        ('monthly', 'Monthly'),
    ]
    
    name = models.CharField(max_length=100)
    period_type = models.CharField(max_length=20, choices=PERIOD_TYPES)
    start_date = models.DateField()
    end_date = models.DateField()
    processed = models.BooleanField(default=False)  # type: ignore
    processed_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return str(self.name)

class PayrollItem(models.Model):
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE)
    payroll_period = models.ForeignKey(PayrollPeriod, on_delete=models.CASCADE)
    gross_salary = models.DecimalField(max_digits=15, decimal_places=2)
    tax_deductions = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    other_deductions = models.DecimalField(max_digits=15, decimal_places=2, default=0)
    net_salary = models.DecimalField(max_digits=15, decimal_places=2)
    paid = models.BooleanField(default=False)  # type: ignore
    paid_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return f"Payroll for {str(self.employee)} - {str(self.payroll_period)}"

class Benefit(models.Model):
    BENEFIT_TYPES = [
        ('health_insurance', 'Health Insurance'),
        ('dental_insurance', 'Dental Insurance'),
        ('retirement_plan', 'Retirement Plan'),
        ('paid_time_off', 'Paid Time Off'),
        ('other', 'Other'),
    ]
    
    employee = models.ForeignKey(Employee, on_delete=models.CASCADE)
    benefit_type = models.CharField(max_length=30, choices=BENEFIT_TYPES)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)
    cost = models.DecimalField(max_digits=15, decimal_places=2)
    created_at = models.DateTimeField(default=timezone.now)
    
    def __str__(self):
        return f"{str(self.name)} - {str(self.employee)}"