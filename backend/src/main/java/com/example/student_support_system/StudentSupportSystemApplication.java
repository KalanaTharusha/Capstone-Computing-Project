package com.example.student_support_system;

import com.example.student_support_system.model.*;
import com.example.student_support_system.model.appointment.Appointment;
import com.example.student_support_system.model.appointment.AppointmentStatus;
import com.example.student_support_system.model.appointment.AppointmentTimeSlot;
import com.example.student_support_system.model.ticket.Ticket;
import com.example.student_support_system.model.ticket.TicketCategory;
import com.example.student_support_system.model.ticket.TicketStatus;
import com.example.student_support_system.model.user.UserAccountStatus;
import com.example.student_support_system.model.user.UserAccountRole;
import com.example.student_support_system.model.user.UserAccount;
import com.example.student_support_system.repository.*;
import com.example.student_support_system.service.FileDataService;
import com.example.student_support_system.util.logging.AppLogger;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.AllArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.AdviceMode;
import org.springframework.context.annotation.Bean;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.multipart.MultipartFile;

import static org.mockito.ArgumentMatchers.notNull;

import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@SpringBootApplication(exclude = { DataSourceAutoConfiguration.class }, scanBasePackages = {
		"com.example.student_support_system" })
@AllArgsConstructor
public class StudentSupportSystemApplication implements CommandLineRunner {

	UserAccountRepository userAccountRepository;
	AppointmentRepository appointmentRepository;
	AppointmentTimeSlotRepository appointmentTimeSlotRepository;
	AnnouncementRepository announcementRepository;
	FileDataRepository fileDataRepository;
	FileDataService fileDataService;
	EventRepository eventRepository;
	ChannelRepository channelRepository;
	TicketRepository ticketRepository;

	public static void main(String[] args) {
		System.out.println(LocalDateTime.now());
		SpringApplication.run(StudentSupportSystemApplication.class, args);
	}

	@Bean
	public BCryptPasswordEncoder bCryptPasswordEncoder() {
		return new BCryptPasswordEncoder();
	}

	@Override
	public void run(String... args) throws Exception {

		LocalDateTime today = LocalDateTime.now();

		// Save demo images/files - for docker env
		try {
			Resource image = fileDataService.loadResource("classpath:images/cc_dummy_image.jpg");
			byte[] content = image.getContentAsByteArray();
			MultipartFile multipartFile = new MockMultipartFile("cc_dummy_image.jpg", "cc_dummy_image.jpg",
					"image/jpeg", content);
			fileDataService.uploadFile(multipartFile, "cc_dummy_image.jpg");

			image = fileDataService.loadResource("classpath:images/sample_boy_dp.jpg");
			content = image.getContentAsByteArray();
			multipartFile = new MockMultipartFile("sample_boy_dp.jpg", "sample_boy_dp.jpg",
					"image/jpeg", content);
			fileDataService.uploadFile(multipartFile, "sample_boy_dp.jpg");

			image = fileDataService.loadResource("classpath:images/sample_girl_dp.jpg");
			content = image.getContentAsByteArray();
			multipartFile = new MockMultipartFile("sample_girl_dp.jpg", "sample_girl_dp.jpg",
					"image/jpeg", content);
			fileDataService.uploadFile(multipartFile, "sample_girl_dp.jpg");

			image = fileDataService.loadResource("classpath:images/sample_admin_dp.jpg");
			content = image.getContentAsByteArray();
			multipartFile = new MockMultipartFile("sample_admin_dp.jpg", "sample_admin_dp.jpg",
					"image/jpeg", content);
			fileDataService.uploadFile(multipartFile, "sample_admin_dp.jpg");

		} catch (Exception e) {
			System.out.println(e.getMessage());
			AppLogger.error("Error when inserting images to database: ", e);
		}

		// Save demo images/files - for runtime env
		try {
			byte[] content = Files.readAllBytes(Paths.get("src/main/resources/images/cc_dummy_image.jpg"));
			MultipartFile multipartFile = new MockMultipartFile("cc_dummy_image.jpg", "cc_dummy_image.jpg",
					"image/jpeg", content);
			fileDataService.uploadFile(multipartFile, "cc_dummy_image.jpg");

			byte[] content2 = Files.readAllBytes(Paths.get("src/main/resources/images/sample_boy_dp.jpg"));
			MultipartFile multipartFile2 = new MockMultipartFile("sample_boy_dp.jpg", "sample_boy_dp.jpg",
					"image/jpeg", content2);
			fileDataService.uploadFile(multipartFile2, "sample_boy_dp.jpg");

			byte[] content3 = Files.readAllBytes(Paths.get("src/main/resources/images/sample_girl_dp.jpg"));
			MultipartFile multipartFile3 = new MockMultipartFile("sample_girl_dp.jpg", "sample_girl_dp.jpg",
					"image/jpeg", content3);
			fileDataService.uploadFile(multipartFile3, "sample_girl_dp.jpg");

			byte[] content4 = Files.readAllBytes(Paths.get("src/main/resources/images/sample_admin_dp.jpg"));
			MultipartFile multipartFile4 = new MockMultipartFile("sample_admin_dp.jpg", "sample_admin_dp.jpg",
					"image/jpeg", content4);
			fileDataService.uploadFile(multipartFile4, "sample_admin_dp.jpg");

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		List<UserAccount> users = new ArrayList<>();
		users.add(UserAccount.builder().id(1L).userId("0000").firstName("Admin").lastName("User")
				.emailAddress("noreply.ccsss@gmail.com").imageId("sample_admin_dp.jpg")
				.role(UserAccountRole.SYSTEM_ADMIN)
				.password("adminpass")
				.userAccountStatus(UserAccountStatus.ACTIVATED).build());
		users.add(UserAccount.builder().id(2L).userId("1111").firstName("Jesse").lastName("Pinkman")
				.emailAddress("noreply.ccsss@gmail.com").imageId("sample_girl_dp.jpg").role(UserAccountRole.STUDENT)
				.password("pass")
				.userAccountStatus(UserAccountStatus.ACTIVATED).build());
		users.add(UserAccount.builder().id(3L).userId("2222").firstName("Walter").lastName("White")
				.emailAddress("noreply.ccsss@gmail.com").imageId("sample_boy_dp.jpg").role(UserAccountRole.LECTURER)
				.password("lecpass")
				.userAccountStatus(UserAccountStatus.ACTIVATED).build());
		users.add(UserAccount.builder().id(4L).userId("3333").firstName("Anjalie").lastName("Gamage")
				.emailAddress("noreply.ccsss@gmail.com").imageId(null).role(UserAccountRole.LECTURER)
				.password("lecpass")
				.userAccountStatus(UserAccountStatus.ACTIVATED).build());
		users.add(UserAccount.builder().id(5L).userId("4444").firstName("Geethanjali").lastName("Wimalaratne")
				.emailAddress("noreply.ccsss@gmail.com").imageId(null).role(UserAccountRole.LECTURER)
				.password("lecpass")
				.userAccountStatus(UserAccountStatus.ACTIVATED).build());
		users.add(UserAccount.builder().id(6L).userId("5555").firstName("Ann").lastName("Fernando")
				.emailAddress("noreply.ccsss@gmail.com").imageId(null).role(UserAccountRole.LECTURER)
				.password("lecpass")
				.userAccountStatus(UserAccountStatus.ACTIVATED).build());
		users.add(UserAccount.builder().id(7L).userId("6666").firstName("Instructor").lastName("User")
				.emailAddress("noreply.ccsss@gmail.com").imageId(null).role(UserAccountRole.INSTRUCTOR)
				.password("inspass")
				.userAccountStatus(UserAccountStatus.ACTIVATED).build());

		PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

		for (UserAccount user : users) {
			user.setPassword(passwordEncoder.encode(user.getPassword()));
			userAccountRepository.save(user);
		}

		UserAccount admin = userAccountRepository.findByUserId("0000").get();
		UserAccount user = userAccountRepository.findByUserId("1111").get();
		UserAccount lecturer = userAccountRepository.findByUserId("2222").get();
		UserAccount lecturer_a = userAccountRepository.findByUserId("3333").get();
		UserAccount lecturer_b = userAccountRepository.findByUserId("4444").get();
		UserAccount lecturer_c = userAccountRepository.findByUserId("5555").get();
		UserAccount instructor = userAccountRepository.findByUserId("6666").get();

		List<AppointmentTimeSlot> timeSlots = new ArrayList<>();
		timeSlots.add(new AppointmentTimeSlot(1L, users.get(3), "Monday", LocalTime.of(10, 30)));
		timeSlots.add(new AppointmentTimeSlot(2L, users.get(3), "Monday", LocalTime.of(11, 30)));
		timeSlots.add(new AppointmentTimeSlot(3L, users.get(3), "Monday", LocalTime.of(12, 30)));

		timeSlots.add(new AppointmentTimeSlot(4L, users.get(3), "Wednesday", LocalTime.of(14, 30)));
		timeSlots.add(new AppointmentTimeSlot(5L, users.get(3), "Wednesday", LocalTime.of(16, 0)));

		timeSlots.add(new AppointmentTimeSlot(6L, users.get(3), "Thursday", LocalTime.of(9, 30)));
		timeSlots.add(new AppointmentTimeSlot(7L, users.get(3), "Thursday", LocalTime.of(12, 30)));
		timeSlots.add(new AppointmentTimeSlot(8L, users.get(3), "Thursday", LocalTime.of(14, 30)));

		timeSlots.add(new AppointmentTimeSlot(9L, users.get(4), "Thursday", LocalTime.of(9, 30)));
		timeSlots.add(new AppointmentTimeSlot(10L, users.get(4), "Thursday", LocalTime.of(12, 30)));

		timeSlots.add(new AppointmentTimeSlot(11L, users.get(4), "Friday", LocalTime.of(10, 30)));
		timeSlots.add(new AppointmentTimeSlot(12L, users.get(4), "Friday", LocalTime.of(12, 0)));

		timeSlots.add(new AppointmentTimeSlot(13L, users.get(5), "Monday", LocalTime.of(9, 30)));
		timeSlots.add(new AppointmentTimeSlot(14L, users.get(5), "Monday", LocalTime.of(12, 30)));
		timeSlots.add(new AppointmentTimeSlot(15L, users.get(5), "Monday", LocalTime.of(14, 30)));

		timeSlots.add(new AppointmentTimeSlot(16L, users.get(5), "Tuesday", LocalTime.of(10, 30)));
		timeSlots.add(new AppointmentTimeSlot(17L, users.get(5), "Tuesday", LocalTime.of(13, 30)));
		timeSlots.add(new AppointmentTimeSlot(18L, users.get(5), "Tuesday", LocalTime.of(14, 30)));

		timeSlots.add(new AppointmentTimeSlot(19L, users.get(5), "Wednesday", LocalTime.of(8, 30)));
		timeSlots.add(new AppointmentTimeSlot(20L, users.get(5), "Wednesday", LocalTime.of(9, 30)));
		timeSlots.add(new AppointmentTimeSlot(21L, users.get(5), "Wednesday", LocalTime.of(10, 30)));

		timeSlots.add(new AppointmentTimeSlot(22L, users.get(5), "Friday", LocalTime.of(8, 30)));
		timeSlots.add(new AppointmentTimeSlot(23L, users.get(5), "Friday", LocalTime.of(9, 30)));
		timeSlots.add(new AppointmentTimeSlot(24L, users.get(5), "Friday", LocalTime.of(10, 30)));
		timeSlots.add(new AppointmentTimeSlot(25L, users.get(5), "Friday", LocalTime.of(14, 30)));

		appointmentTimeSlotRepository.saveAll(timeSlots);

		List<Appointment> appointments = new ArrayList<>();

		appointments.add(new Appointment(1L, "Financial Aid Application Assistance", user, lecturer_a,
				LocalDate.of(2024, 4, 24), LocalTime.of(9, 30), LocalDateTime.now(), LocalDateTime.now(),
				"TBA", AppointmentStatus.ACCEPTED));
		appointments.add(new Appointment(2L, "Academic Advising Session", user, lecturer_b,
				LocalDate.of(2024, 3, 21), LocalTime.of(11, 30), LocalDateTime.now(), LocalDateTime.now(),
				"TBA", AppointmentStatus.PENDING));
		appointments.add(new Appointment(3L, "Academic Advising Session", user, lecturer_c,
				LocalDate.of(2024, 3, 17), LocalTime.of(7, 30), LocalDateTime.now(), LocalDateTime.now(),
				"Office 304", AppointmentStatus.ACCEPTED));
		appointments.add(new Appointment(4L, "Counseling Services Appointment", user, lecturer_a,
				LocalDate.of(2024, 3, 9), LocalTime.of(4, 30), LocalDateTime.now(), LocalDateTime.now(),
				"Canceled", AppointmentStatus.REJECTED));

		appointments.add(new Appointment(5L, "Career Planning Workshop", user, lecturer_c, LocalDate.of(2024, 4, 25),
				LocalTime.of(11, 0), LocalDateTime.now(), LocalDateTime.now(), "TBA",
				AppointmentStatus.PENDING));
		appointments.add(new Appointment(6L, "Academic Advising Session", user, lecturer_b, LocalDate.of(2024, 4, 26),
				LocalTime.of(10, 30), LocalDateTime.now(), LocalDateTime.now(), "TBA",
				AppointmentStatus.ACCEPTED));
		appointments.add(new Appointment(7L, "Research Progress Meeting with Supervisor", user, lecturer_c,
				LocalDate.of(2024, 4, 22), LocalTime.of(15, 30), LocalDateTime.now(), LocalDateTime.now(),
				"Office 304", AppointmentStatus.REJECTED));
		appointments.add(new Appointment(8L, "Meeting with Student Counselor", user, lecturer_a,
				LocalDate.of(2024, 4, 23), LocalTime.of(8, 30), LocalDateTime.now(), LocalDateTime.now(),
				"Canceled", AppointmentStatus.REJECTED));

		appointments.add(new Appointment(9L, "Academic Advising Session", user, lecturer_a,
				LocalDate.of(2024, 6, 10), LocalTime.of(16, 0), LocalDateTime.now(), LocalDateTime.now(),
				"TBA", AppointmentStatus.PENDING));
		appointments.add(new Appointment(10L, "Meeting with Student Counselor", user, lecturer_a,
				LocalDate.of(2024, 5, 18), LocalTime.of(12, 0), LocalDateTime.now(), LocalDateTime.now(),
				"TBA", AppointmentStatus.PENDING));
		appointments.add(new Appointment(11L, "Research Progress Meeting with Supervisor", user, lecturer_c,
				LocalDate.of(2024, 5, 20), LocalTime.of(15, 30), LocalDateTime.now(), LocalDateTime.now(),
				"Office 304", AppointmentStatus.PENDING));
		appointments.add(new Appointment(12L, "Career Planning Workshop", user, lecturer_c,
				LocalDate.of(2024, 5, 29), LocalTime.of(7, 30), LocalDateTime.now(), LocalDateTime.now(),
				"Canceled", AppointmentStatus.REJECTED));

		LocalDate tdy = LocalDate.now();
		LocalTime currentTime = LocalTime.now();

		appointmentRepository.saveAll(appointments);

		List<Channel> channels = new ArrayList<>();
		channels.add(new Channel(1L, "ISEC3004", "Official group for ISEC3004 Module", new ArrayList<>(),
				new ArrayList<>(), "Modules", null));
		channels.add(new Channel(2L, "COMP2000", "Official group for COMP2000 Module", new ArrayList<>(),
				new ArrayList<>(), "Modules", null));
		channels.add(
				new Channel(3L, "ISAD1000", "Official group for ISAD1000 Module", new ArrayList<>(), new ArrayList<>(),
						"Modules", null));
		channels.add(
				new Channel(4L, "COMP3000", "Official group for COMP3000 Module", new ArrayList<>(), new ArrayList<>(),
						"Modules", null));
		channels.add(
				new Channel(5L, "COMP2006", "Official group for COMP2006 Module", new ArrayList<>(), new ArrayList<>(),
						"Modules", null));
		channels.add(
				new Channel(6L, "ISAD3000", "Official group for ISAD3000 Module", new ArrayList<>(), new ArrayList<>(),
						"Modules", null));
		channels.add(
				new Channel(7L, "ISEC2000", "Official group for ISEC2000 Module", new ArrayList<>(), new ArrayList<>(),
						"Modules", null));
		channels.add(
				new Channel(8L, "CSIT1030", "Official group for CSIT1030 Module", new ArrayList<>(), new ArrayList<>(),
						"Modules", null));
		channels.add(
				new Channel(9L, "CSIT1030", "Official group for CSIT1030 Module", new ArrayList<>(), new ArrayList<>(),
						"Modules", null));
		channels.add(
				new Channel(10L, "INDE1001", "Official group for INDE1001 Module", new ArrayList<>(), new ArrayList<>(),
						"Modules", null));
		channels.add(new Channel(11L, "CCMU", "Curtin Colombo Media Unit", new ArrayList<>(), new ArrayList<>(),
				"Clubs", null));
		channels.add(new Channel(12L, "CCET", "Curtin Colombo Events Team", new ArrayList<>(), new ArrayList<>(),
				"Clubs", null));
		channels.add(new Channel(13L, "CCGC", "Curtin Colombo Gaming Club", new ArrayList<>(), new ArrayList<>(),
				"Clubs", null));
		channels.add(new Channel(14L, "CCFC", "Curtin Colombo Food Club", new ArrayList<>(), new ArrayList<>(),
				"Clubs", null));
		channels.add(new Channel(15L, "CCMC", "Curtin Colombo Media Club", new ArrayList<>(), new ArrayList<>(),
				"Clubs", null));

		channels.add(new Channel(16L, "CCSC", "Curtin Colombo Soccer Club", new ArrayList<>(), new ArrayList<>(),
				"Sports", null));
		channels.add(new Channel(17L, "CCBC", "Curtin Colombo Basketball Club", new ArrayList<>(), new ArrayList<>(),
				"Sports", null));

		channels.add(new Channel(18L, "Curtin Freshers' Week", "Official event group for Curtin Freshers' Week",
				new ArrayList<>(), new ArrayList<>(),
				"Events", null));
		channels.add(new Channel(19L, "Curtin Hackathon", "Official event group for Curtin Hackathon",
				new ArrayList<>(), new ArrayList<>(),
				"Events", null));

		channels.add(new Channel(20L, "Curtin Library Resources", "Offical group for Curtin Library Resources",
				new ArrayList<>(), new ArrayList<>(),
				"Academic", null));
		channels.add(new Channel(21L, "Curtin Scholarships and Financial Aid",
				"Offical group for Curtin Scholarships and Financial Aid",
				new ArrayList<>(), new ArrayList<>(),
				"Academic", null));

		channels.add(new Channel(22L, "Curtin Academic Staff", "Offical group for Curtin Academic Staff",
				new ArrayList<>(), new ArrayList<>(),
				"Staff", null));
		channels.add(new Channel(23L, "Curtin Administrative Staff", "Offical group for Curtin Administrative Staff",
				new ArrayList<>(), new ArrayList<>(),
				"Staff", null));

		channelRepository.saveAll(channels);

		JsonNode description = new ObjectMapper().readTree(
				"[{\"insert\":\"Our mobile app is your central hub for accessing a wide array of support services designed specifically for our students. Whether you're seeking academic assistance, exploring campus resources, or needing guidance on various matters, our app offers a convenient platform to address your needs effectively.\\n\\nWith the Curtin Colombo Student Support App, you can easily schedule appointments with advisors, tutors, or other support staff to receive personalized assistance tailored to your academic journey. Additionally, our integrated chat service allows you to connect with university staff and fellow students for quick answers to your questions or to engage in discussions related to your studies or campus life.\\n\\nThe app also features a ticket submission system, enabling you to report issues or request assistance from university departments. Whether it's a technical problem, facility maintenance issue, or general inquiry, our ticketing system ensures that your concerns are addressed promptly and efficiently.\\n\\nDownload the Curtin Colombo Student Support App today and take advantage of these features to streamline your university experience. Stay connected with our campus community, make appointments with ease, engage in real-time chats, and submit tickets for any assistance you may need.\\n\"}]");

		JsonNode alertBody = new ObjectMapper().readTree(
				"[{\"insert\":\"Dear Student,\\nThe Centrally Scheduled FINAL Assessment/Examination Timetable for Semester 1, 2024 is now available.\\nView your personalised timetable. Centrally scheduled assessment and exams, including Curtin OUA exams are held during the examination period and these will be managed by the Progression, Assessment and Awards team.  Many assessments and exams will be centrally scheduled during the formal examination period.  All other assessments not showing on your personalised timetable are managed by your School.\\nExam venues\\nIf you are due to sit a face-to-face exam at Curtin Bentley Perth or Curtin Kalgoorlie Campuses, examination venues will be published to your personalised timetable two weeks prior to the examination period. All other Curtin Campuses will advise students of their examination venues.  All students are responsible for attending the correct venue for their examination as advised on their personalised final timetable.\\nPreparing for and attending your exams\\nBefore you attend your assessment or exam, it is important that you are prepared and know what is expected of you during this time. Please visit our website for further details.\\nStudents who fail to sit a scheduled assessment/examination because they misread their timetable or accepted incorrect information from another person are not entitled to sit the assessment/examination at any other time or receive any other concession (i.e., deferred exam)\\nKey dates\\n Key dates are available via our website\\nPlease contact Curtin Connect if you have any further queries. We wish you the very best for your upcoming assessment/s and/or examination/s. \\n\\nKind regards, \\nProgression, Assessment and Awards.\\n\"}]");

		List<Announcement> announcements = new ArrayList<>();

		for (int i = 0; i < 50; i++) {
			announcements.add(
					new Announcement((long) (i + 1), AnnouncementCategory.ACADEMIC, "Title " + (i + 1), description,
							"cc_dummy_image.jpg", today.minusDays(50 - i), admin, today.minusDays(50 - i), admin));
		}

		for (int i = 49; i > 38; i--) {
			announcements.get(i).setTitle("Welcome to the Curtin Colombo Student Support App!");
		}

		announcements.get(49).setCategory(AnnouncementCategory.IMPORTANT);
		announcements.get(43).setCategory(AnnouncementCategory.IMPORTANT);

		Announcement alert = new Announcement(
				(long) 106,
				AnnouncementCategory.ALERT,
				"Centrally Scheduled Final Assessment / Examination Timetable - Semester 1, 2024",
				alertBody,
				"cc_dummy_image.jpg",
				today,
				admin,
				today,
				admin);

		announcements.add(alert);

		announcementRepository.saveAll(announcements);

		List<Event> events = new ArrayList<>();

		events.add(new Event(1L, "Guest Lecture: Robotics in Healthcare", admin, admin, LocalDateTime.now(),
				LocalDateTime.now(), LocalDate.of(2024, 3, 12), LocalTime.of(17, 30), LocalTime.of(19, 0)));

		events.add(new Event(2L, "Career Fair: Tech Industry", admin, admin, LocalDateTime.now(), LocalDateTime.now(),
				LocalDate.of(2024, 4, 5), LocalTime.of(10, 0), LocalTime.of(16, 0)));

		events.add(new Event(3L, "Student Orientation Week", admin, admin, LocalDateTime.now(), LocalDateTime.now(),
				LocalDate.of(2024, 8, 20), LocalTime.of(9, 0), LocalTime.of(17, 0)));

		events.add(new Event(4L, "Annual Sports Day", admin, admin, LocalDateTime.now(), LocalDateTime.now(),
				LocalDate.of(2024, 5, 15), LocalTime.of(13, 0), LocalTime.of(18, 0)));

		events.add(new Event(5L, "Research Symposium: Future of Renewable Energy", admin, admin, LocalDateTime.now(),
				LocalDateTime.now(), LocalDate.of(2024, 7, 10), LocalTime.of(9, 30), LocalTime.of(16, 30)));

		events.add(new Event(6L, "Music Concert: University Band Showcase", admin, admin, LocalDateTime.now(),
				LocalDateTime.now(), LocalDate.of(2024, 6, 28), LocalTime.of(19, 0), LocalTime.of(21, 30)));

		events.add(new Event(7L, "Career Development Workshop: Resume Building", admin, admin, LocalDateTime.now(),
				LocalDateTime.now(), LocalDate.of(2024, 4, 18), LocalTime.of(15, 0), LocalTime.of(16, 30)));

		events.add(new Event(8L, "International Food Festival", admin, admin, LocalDateTime.now(), LocalDateTime.now(),
				LocalDate.of(2024, 9, 5), LocalTime.of(11, 0), LocalTime.of(20, 0)));

		events.add(new Event(9L, "Hackathon: AI and Machine Learning", admin, admin, LocalDateTime.now(),
				LocalDateTime.now(), LocalDate.of(2024, 10, 20), LocalTime.of(9, 0), LocalTime.of(18, 0)));

		events.add(new Event(10L, "Drama Club Production: Shakespeare's 'Hamlet'", admin, admin, LocalDateTime.now(),
				LocalDateTime.now(), LocalDate.of(2024, 11, 15), LocalTime.of(19, 30), LocalTime.of(21, 0)));

		events.add(new Event(11L, "Hackathon - Coding Competition", admin, admin, today, today, LocalDate.now(),
				LocalTime.of(9, 30), LocalTime.of(17, 30)));

		eventRepository.saveAll(events);

		JsonNode forwardTo = new ObjectMapper().readTree("[]");

		List<Ticket> tickets = new ArrayList<>();
		tickets.add(new Ticket(1L, user, LocalDateTime.of(2024, 3, 24, 18, 27, 42),
				LocalDateTime.of(2024, 2, 26, 9, 12, 32), forwardTo, "Payment options",
				"My payments fail to go through, are there other payment options other than those stated?",
				TicketStatus.REPLIED, TicketCategory.Payments));
		tickets.add(new Ticket(2L, user, LocalDateTime.of(2024, 3, 30, 12, 41, 50),
				LocalDateTime.of(2024, 3, 30, 14, 5, 34), forwardTo, "CCNA tests",
				"The tests require activation for me to be able to complete them.", TicketStatus.CLOSED,
				TicketCategory.Academic));
		tickets.add(new Ticket(3L, user, LocalDateTime.of(2024, 4, 1, 12, 45, 43),
				LocalDateTime.of(2024, 4, 2, 20, 23, 42), forwardTo, "Attending exams",
				"I broke both my legs and all examinations this week are held on the first floor.",
				TicketStatus.PENDING, TicketCategory.Accessibility));
		tickets.add(new Ticket(4L, user, LocalDateTime.of(2024, 4, 2, 13, 56, 2),
				LocalDateTime.of(2024, 4, 3, 10, 23, 43), forwardTo, "Basketball tournament",
				"I broke both my legs and will not be able to participate in the upcoming tournaments",
				TicketStatus.REPLIED, TicketCategory.Sports));

		ticketRepository.saveAll(tickets);

		AppLogger.info("Curtin Assist backend started...");
	}
}
