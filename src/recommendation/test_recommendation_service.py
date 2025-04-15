import sys
import os
import unittest
from unittest.mock import MagicMock
from demo_pb2 import ListRecommendationsRequest

# Make sure module is discoverable
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from recommendation_server import RecommendationService


class TestRecommendationService(unittest.TestCase):
    def test_list_recommendations(self):
        # Import the module after path fix
        import recommendation_server

        # Inject mock logger, tracer, and product_catalog_stub
        recommendation_server.logger = MagicMock()
        recommendation_server.tracer = MagicMock()
        recommendation_server.product_catalog_stub = MagicMock()

        # Mock tracer context manager
        mock_span = MagicMock()
        recommendation_server.tracer.start_as_current_span.return_value.__enter__.return_value = mock_span

        # Setup fake product catalog data
        fake_products = [
            MagicMock(id="prod1"),
            MagicMock(id="prod2"),
            MagicMock(id="prod3"),
            MagicMock(id="prod4"),
            MagicMock(id="prod5"),
            MagicMock(id="prod6"),
        ]
        recommendation_server.product_catalog_stub.ListProducts.return_value.products = fake_products

        # Prepare request
        service = RecommendationService()
        request = ListRecommendationsRequest(product_ids=["prod1", "prod2"])

        # Act
        response = service.ListRecommendations(request, MagicMock())

        # Assert
        self.assertTrue(len(response.product_ids) > 0)
        self.assertNotIn("prod1", response.product_ids)
        self.assertNotIn("prod2", response.product_ids)
        self.assertLessEqual(len(response.product_ids), 5)


if __name__ == '__main__':
    unittest.main()