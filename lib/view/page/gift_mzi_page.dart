import 'package:flutter_weather/commom_import.dart';

class GiftMziPage extends StatefulWidget {
  final String typeUrl;

  GiftMziPage({Key key, @required this.typeUrl}) : super(key: key);

  @override
  State createState() => GiftMziState();
}

class GiftMziState extends PageState<GiftMziPage> with MustKeepAliveMixin {
  final _viewModel = GiftMziViewModel();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _viewModel.init(typeUrl: widget.typeUrl);
    _scrollController.addListener(() {
      // 滑到底部加载更多
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _viewModel.loadMore();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    String errorText = "";
    switch (widget.typeUrl) {
      case "mm":
        errorText = AppText.of(context).beachGirlFail;
        break;
      case "hot":
        errorText = AppText.of(context).mostHotFail;
        break;
      case "taiwan":
        errorText = AppText.of(context).taiwanGirFail;
        break;
      case "xinggan":
        errorText = AppText.of(context).sexGirlFail;
        break;
      case "japan":
        errorText = AppText.of(context).japanGirlFail;
        break;
    }
    bindErrorStream(_viewModel.error.stream,
        errorText: errorText,
        retry: () => _viewModel.loadData(type: LoadType.NEW_LOAD));
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: scafKey,
      body: LoadingView(
        loadingStream: _viewModel.isLoading.stream,
        child: StreamBuilder(
          stream: _viewModel.data.stream,
          builder: (context, snapshot) {
            final List<MziData> list = snapshot.data ?? List();

            return RefreshIndicator(
              onRefresh: () => _viewModel.loadData(type: LoadType.REFRESH),
              child: StaggeredGridView.countBuilder(
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                    parent: const ClampingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
                itemCount: list.length,
                staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                itemBuilder: (context, index) {
                  final data = list[index];
                  final headers = Map<String, String>();
                  headers["Referer"] = data.refer;

                  return GestureDetector(
                    onTap: () =>
                        push(context, page: GiftMziImagePage(data: data)),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: data.width / data.height,
                          child: NetImage(
                            headers: headers,
                            url: data.url,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 6, bottom: 6),
                          child: Icon(
                            Icons.photo_library,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
