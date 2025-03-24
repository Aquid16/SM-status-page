from django.test import TestCase
from .models import Component
from django.urls import reverse

class ComponentTests(TestCase):

    def setUp(self):
        self.component_data = {'name': 'Database', 'status': 'Operational'}
        self.component = Component.objects.create(**self.component_data)

    def test_create_component(self):
        component = Component.objects.create(name="New Component", status="Down")
        self.assertEqual(component.name, "New Component")
        self.assertEqual(component.status, "Down")

    def test_component_api(self):
        url = reverse('components:component_list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)

    def test_component_detail(self):
        url = reverse('components:component', kwargs={'pk': self.component.pk})
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)
