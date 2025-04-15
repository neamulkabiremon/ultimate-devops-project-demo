import unittest
from unittest.mock import patch, MagicMock
from demo_pb2 import ListRecommendationsRequest
from recommendation import RecommendationService


class TestRecommendationService(unittest.TestCase):
    @patch("recommendation.product_catalog_stub")
    def test_list_recommendations(self, mock_catalog_stub):
        # Arrange
        # Fake product catalog response
        fake_products = [
            MagicMock(id="prod1"),
            MagicMock(id="prod2"),
            MagicMock(id="prod3"),
            MagicMock(id="prod4"),
            MagicMock(id="prod5"),
            MagicMock(id="prod6"),
        ]
        mock_catalog_stub.ListProducts.return_value.products = fake_products

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