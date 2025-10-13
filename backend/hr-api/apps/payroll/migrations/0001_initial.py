# Generated migration file for payroll app
from django.db import migrations, models
import django.utils.timezone
import django.db.models.deletion

class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('employees', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='PayrollPeriod',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('period_type', models.CharField(choices=[('weekly', 'Weekly'), ('biweekly', 'Bi-weekly'), ('monthly', 'Monthly')], max_length=20)),
                ('start_date', models.DateField()),
                ('end_date', models.DateField()),
                ('processed', models.BooleanField(default=False)),  # type: ignore
                ('processed_at', models.DateTimeField(blank=True, null=True)),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
            ],
        ),
        migrations.CreateModel(
            name='Benefit',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('benefit_type', models.CharField(choices=[('health_insurance', 'Health Insurance'), ('dental_insurance', 'Dental Insurance'), ('retirement_plan', 'Retirement Plan'), ('paid_time_off', 'Paid Time Off'), ('other', 'Other')], max_length=30)),
                ('name', models.CharField(max_length=100)),
                ('description', models.TextField(blank=True)),
                ('start_date', models.DateField()),
                ('end_date', models.DateField(blank=True, null=True)),
                ('cost', models.DecimalField(decimal_places=2, max_digits=15)),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('employee', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='employees.employee')),
            ],
        ),
        migrations.CreateModel(
            name='PayrollItem',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('gross_salary', models.DecimalField(decimal_places=2, max_digits=15)),
                ('tax_deductions', models.DecimalField(decimal_places=2, default=0, max_digits=15)),
                ('other_deductions', models.DecimalField(decimal_places=2, default=0, max_digits=15)),
                ('net_salary', models.DecimalField(decimal_places=2, max_digits=15)),
                ('paid', models.BooleanField(default=False)),  # type: ignore
                ('paid_at', models.DateTimeField(blank=True, null=True)),
                ('created_at', models.DateTimeField(default=django.utils.timezone.now)),
                ('employee', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='employees.employee')),
                ('payroll_period', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='payroll.payrollperiod')),
            ],
        ),
    ]