package oteldemo;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import oteldemo.Demo.Ad;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
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
    try {
      Field field = AdService.class.getDeclaredField("service");
      field.setAccessible(true);
      return (AdService) field.get(null);
    } catch (Exception e) {
      throw new RuntimeException("Could not access AdService singleton for testing", e);
    }
  }

  @Test
  void getAdsByCategory_returnsExpectedAds() throws Exception {
    Method method = AdService.class.getDeclaredMethod("getAdsByCategory", String.class);
    method.setAccessible(true);
    @SuppressWarnings("unchecked")
    Collection<Ad> binocularsAds = (Collection<Ad>) method.invoke(adService, "binoculars");

    assertFalse(binocularsAds.isEmpty(), "Expected non-empty list for 'binoculars'");
    assertTrue(
        binocularsAds.stream().anyMatch(ad -> ad.getText().contains("Binoculars")));
  }

  @Test
  void getAdsByCategory_returnsEmptyForUnknownCategory() throws Exception {
    Method method = AdService.class.getDeclaredMethod("getAdsByCategory", String.class);
    method.setAccessible(true);
    @SuppressWarnings("unchecked")
    Collection<Ad> unknownAds = (Collection<Ad>) method.invoke(adService, "nonexistent-category");

    assertTrue(unknownAds.isEmpty(), "Expected empty list for unknown category");
  }

  @Test
  void getRandomAds_returnsTwoAds() throws Exception {
    Method method = AdService.class.getDeclaredMethod("getRandomAds");
    method.setAccessible(true);
    @SuppressWarnings("unchecked")
    List<Ad> ads = (List<Ad>) method.invoke(adService);

    assertEquals(2, ads.size(), "Expected exactly 2 random ads");
  }
}