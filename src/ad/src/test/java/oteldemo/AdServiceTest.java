package oteldemo;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import oteldemo.Demo.Ad;

import java.util.Collection;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class AdServiceTest {

    private AdService adService;

    @BeforeEach
    void setUp() {
        adService = getSingletonInstance();
    }

    private AdService getSingletonInstance() {
        // Reflection hack to access the private static singleton, for testing purposes only
        try {
            var field = AdService.class.getDeclaredField("service");
            field.setAccessible(true);
            return (AdService) field.get(null);
        } catch (Exception e) {
            throw new RuntimeException("Could not access AdService singleton for testing", e);
        }
    }

    @Test
    void getAdsByCategory_returnsExpectedAds() {
        Collection<Ad> binocularsAds = adService.getAdsByCategory("binoculars");
        assertFalse(binocularsAds.isEmpty(), "Expected non-empty list for 'binoculars'");
        assertTrue(binocularsAds.stream().anyMatch(ad -> ad.getText().contains("Binoculars")));
    }

    @Test
    void getAdsByCategory_returnsEmptyForUnknownCategory() {
        Collection<Ad> unknownAds = adService.getAdsByCategory("nonexistent-category");
        assertTrue(unknownAds.isEmpty(), "Expected empty list for unknown category");
    }

    @Test
    void getRandomAds_returnsTwoAds() {
        List<Ad> ads = adService.getRandomAds();
        assertEquals(2, ads.size(), "Expected exactly 2 random ads");
    }
}