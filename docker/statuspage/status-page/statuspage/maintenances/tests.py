from django.test import TestCase
from .models import Maintenance
from django.urls import reverse

class MaintenanceTests(TestCase):

    def setUp(self):
        self.maintenance_data = {'name': 'Database Maintenance', 'status': 'Scheduled'}
        self.maintenance = Maintenance.objects.create(**self.maintenance_data)

    def test_create_maintenance(self):
        maintenance = Maintenance.objects.create(name="System Upgrade", status="Completed")
        self.assertEqual(maintenance.name, "System Upgrade")
        self.assertEqual(maintenance.status, "Completed")

    def test_maintenance_api(self):
        url = reverse('maintenances:maintenance_list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)

    def test_maintenance_detail(self):
        url = reverse('maintenances:maintenance', kwargs={'pk': self.maintenance.pk})
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)
