import sys
import os
import unittest
from unittest.mock import MagicMock
from demo_pb2 import ListRecommendationsRequest

# Fix Python path so we can import the server module
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from recommendation_server import RecommendationService


class TestRecommendationService(unittest.TestCase):
    def test_list_recommendations(self):
        # Arrange
        service = RecommendationService()

        # Inject mock product_catalog_stub into the service's global scope
        fake_products = [
            MagicMock(id="prod1"),
            MagicMock(id="prod2"),
            MagicMock(id="prod3"),
            MagicMock(id="prod4"),
            MagicMock(id="prod5"),
            MagicMock(id="prod6"),
        ]
        import recommendation_server
        recommendation_server.product_catalog_stub = MagicMock()
        recommendation_server.product_catalog_stub.ListProducts.return_value.products = fake_products

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