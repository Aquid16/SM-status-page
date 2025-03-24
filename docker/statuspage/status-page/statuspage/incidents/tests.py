from django.test import TestCase
from statuspage.incidents.models import Incident
from django.urls import reverse

class IncidentTests(TestCase):

    def setUp(self):
        self.incident_data = {'name': 'Server Down', 'status': 'Ongoing'}
        self.incident = Incident.objects.create(**self.incident_data)

    def test_create_incident(self):
        incident = Incident.objects.create(name="Database Issue", status="Resolved")
        self.assertEqual(incident.name, "Database Issue")
        self.assertEqual(incident.status, "Resolved")

    def test_incident_api(self):
        url = reverse('incidents:incident_list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)

    def test_incident_detail(self):
        url = reverse('incidents:incident', kwargs={'pk': self.incident.pk})
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)
