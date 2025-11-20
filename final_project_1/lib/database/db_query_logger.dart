import 'dart:developer' as developer;

void logSql(String sql) {
  developer.log('[DRIFT SQL] $sql', name: 'db_query_logger');
}
