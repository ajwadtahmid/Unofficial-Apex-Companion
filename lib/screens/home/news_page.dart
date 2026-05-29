import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/news_article.dart';
import '../../utils/notifications.dart';
import '../../utils/theme.dart';

class NewsPage extends StatelessWidget {
  final List<NewsArticle> articles;
  const NewsPage({super.key, required this.articles});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Latest News')),
      body: articles.isEmpty
          ? const Center(
              child: Text(
                'No news right now.',
                style: TextStyle(color: AppTheme.muted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppTheme.md),
              itemCount: articles.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppTheme.sm),
              itemBuilder: (context, i) {
                final article = articles[i];
                return Material(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    onTap: () async {
                      if (article.link.isNotEmpty) {
                        final uri = Uri.tryParse(article.link);
                        if (uri != null) {
                          final ok = await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                          if (!ok && context.mounted) {
                            context.showMessage('Could not open link');
                          }
                        }
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppTheme.radiusMd),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: article.imageUrl,
                              height: AppTheme.newsImageHeight,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (ctx, url) => Container(
                                height: AppTheme.newsImageHeight,
                                color: AppTheme.surface2,
                              ),
                              errorWidget: (ctx, url, err) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(AppTheme.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              if (article.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  article.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              if (article.link.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                const Text(
                                  'Read more →',
                                  style: TextStyle(
                                    color: AppTheme.accent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
