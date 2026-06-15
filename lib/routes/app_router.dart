import 'package:flutter/material.dart';
import '../screens/index.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case '/splash':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case '/register':
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      // Admin Routes
      case '/admin/home':
        return MaterialPageRoute(
          builder: (_) => const AdminHomeScreen(),
          settings: settings,
        );
      case '/admin/create-event':
        return MaterialPageRoute(
          builder: (_) => const CreateEventScreen(),
          settings: settings,
        );
      case '/admin/list-events':
        return MaterialPageRoute(
          builder: (_) => const ListEventsScreen(),
          settings: settings,
        );

      // User Routes
      case '/user/home':
        return MaterialPageRoute(
          builder: (_) => const UserHomeScreen(),
          settings: settings,
        );

      default:
        if (settings.name?.startsWith('/admin/edit-event/') ?? false) {
          final eventId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (_) => EditEventScreen(eventId: eventId),
            settings: settings,
          );
        }

        if (settings.name?.startsWith('/admin/participants/') ?? false) {
          final eventId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (_) => ParticipantsScreen(eventId: eventId),
            settings: settings,
          );
        }

        if (settings.name?.startsWith('/user/event-detail/') ?? false) {
          final eventId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (_) => EventDetailScreen(eventId: eventId),
            settings: settings,
          );
        }

        if (settings.name?.startsWith('/user/ticket-detail/') ?? false) {
          final ticketId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (_) => TicketDetailScreen(ticketId: ticketId),
            settings: settings,
          );
        }

        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}
