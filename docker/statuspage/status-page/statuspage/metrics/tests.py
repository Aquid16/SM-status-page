from django.test import TestCase
from statuspage.metrics.models import Metric
from django.urls import reverse

class MetricTests(TestCase):

    def setUp(self):
        self.metric_data = {'name': 'Page Load Time', 'value': '200ms'}
        self.metric = Metric.objects.create(**self.metric_data)

    def test_create_metric(self):
        metric = Metric.objects.create(name="API Response Time", value="150ms")
        self.assertEqual(metric.name, "API Response Time")
        self.assertEqual(metric.value, "150ms")

    def test_metric_api(self):
        url = reverse('metrics:metric_list')
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)

    def test_metric_detail(self):
        url = reverse('metrics:metric', kwargs={'pk': self.metric.pk})
        response = self.client.get(url)
        self.assertEqual(response.status_code, 200)
