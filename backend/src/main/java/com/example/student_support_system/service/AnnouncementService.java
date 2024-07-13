package com.example.student_support_system.service;

import com.example.student_support_system.exception.EntityNotFoundException;
import com.example.student_support_system.model.Announcement;
import com.example.student_support_system.model.AnnouncementCategory;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.repository.AnnouncementRepository;
import org.springframework.cache.annotation.CacheConfig;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class AnnouncementService {
    private final AnnouncementRepository announcementRepository;
    private final FcmService fcmService;

    public static final String ANNOUNCEMENT_CACHE = "announcements";

    public AnnouncementService(AnnouncementRepository announcementRepository,FcmService fcmService){
        this.announcementRepository = announcementRepository;
        this.fcmService = fcmService;
    }

    @Cacheable(value = ANNOUNCEMENT_CACHE)
    public List<Announcement> getAllAnnouncements() throws InterruptedException {
        // TODO: remove this after testing @Kalana
        Thread.sleep(3000);
        return announcementRepository.findAll();
    }

    @CachePut(value = ANNOUNCEMENT_CACHE, key = "#result.id")
    @CacheEvict(value = ANNOUNCEMENT_CACHE, allEntries = true)
    public Announcement createAnnouncement(Announcement announcement) {
        fcmService.sendNotificationToAll("New announcement",announcement.getTitle());
        return announcementRepository.save(announcement);
    }


    @CachePut(value = ANNOUNCEMENT_CACHE, key = "#result.id")
    @CacheEvict(value = ANNOUNCEMENT_CACHE, allEntries = true)
    public Announcement updateAnnouncement(Long id, UserAccount updatedBy, Announcement updateAnnouncement) {
        Optional<Announcement> announcement = announcementRepository.findById(id);
        Announcement unwrappedAnnouncement = unwrapAnnouncement(announcement, String.valueOf(id));
        unwrappedAnnouncement.setTitle(updateAnnouncement.getTitle());
        unwrappedAnnouncement.setDescription(updateAnnouncement.getDescription());
        unwrappedAnnouncement.setCategory(updateAnnouncement.getCategory());
        unwrappedAnnouncement.setImageId(updateAnnouncement.getImageId());
        unwrappedAnnouncement.setUpdateBy(updatedBy);
        unwrappedAnnouncement.setUpdateDate(LocalDateTime.now());

        return announcementRepository.save(unwrappedAnnouncement);
    }

    @Cacheable(value = ANNOUNCEMENT_CACHE, key = "#id")
    public Announcement getAnnouncement(Long id) {
        Optional<Announcement> announcement = announcementRepository.findById(id);
        return unwrapAnnouncement(announcement, id.toString());
    }

    public List<Announcement> search(String term) {
        return announcementRepository.findAllByTitleContainingIgnoreCase(term, PageRequest.of(0, 20, Sort.by("updateDate").descending()));
    }

    public Page<Announcement> getAnnouncementsWithPagination(int offset, int pageSize) {
        return announcementRepository.findAll(PageRequest.of(offset, pageSize, Sort.by("updateDate").descending()));
    }

    public List<Announcement> getAllAnnouncementsByDate(LocalDateTime startDate, LocalDateTime endDate) {
        return announcementRepository.findAnnouncementsByCreateDateBetween(startDate, endDate);
    }

    public List<Announcement> getAlerts() {
        return announcementRepository.findAnnouncementsByCategoryOrderByUpdateDateDesc(AnnouncementCategory.ALERT);
    }

    @CacheEvict(value = "announcements", allEntries = true)
    public void deleteAnnouncement(Long id) {
        announcementRepository.deleteById(id);
    }

    static Announcement unwrapAnnouncement(Optional<Announcement> entity, String id) {
        if (entity.isPresent()) return entity.get();
        else throw new EntityNotFoundException(id, Announcement.class);
    }
}
