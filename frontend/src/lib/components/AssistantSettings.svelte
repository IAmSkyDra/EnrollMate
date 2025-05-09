<script lang="ts">
	import type { readAndCompressImage } from "browser-image-resizer";
	import type { Model } from "$lib/types/Model";
	import type { Assistant } from "$lib/types/Assistant";

	import i18n from "$lib/i18n";
	import { onMount } from "svelte";
	import { applyAction, enhance } from "$app/forms";
	import { page } from "$app/stores";
	import { base } from "$app/paths";
	import CarbonPen from "~icons/carbon/pen";
	import CarbonUpload from "~icons/carbon/upload";
	import CarbonHelpFilled from "~icons/carbon/help";
	import CarbonSettingsAdjust from "~icons/carbon/settings-adjust";
	import CarbonTools from "~icons/carbon/tools";

	import { useSettingsStore } from "$lib/stores/settings";
	import { isHuggingChat } from "$lib/utils/isHuggingChat";
	import IconInternet from "./icons/IconInternet.svelte";
	import TokensCounter from "./TokensCounter.svelte";
	import HoverTooltip from "./HoverTooltip.svelte";
	import { findCurrentModel } from "$lib/utils/models";
	import AssistantToolPicker from "./AssistantToolPicker.svelte";

	type ActionData = {
		error: boolean;
		errors: {
			field: string | number;
			message: string;
		}[];
	} | null;

	type AssistantFront = Omit<Assistant, "_id" | "createdById"> & { _id: string };

	interface Props {
		form: ActionData;
		assistant?: AssistantFront | undefined;
		models?: Model[];
	}

	let { form = $bindable(), assistant = undefined, models = [] }: Props = $props();

	let files: FileList | null = $state(null);
	const settings = useSettingsStore();
	let modelId = $state("");
	let systemPrompt = $state(assistant?.preprompt ?? "");
	let dynamicPrompt = $state(assistant?.dynamicPrompt ?? false);
	let showModelSettings = $state(Object.values(assistant?.generateSettings ?? {}).some((v) => !!v));

	let compress: typeof readAndCompressImage | null = $state(null);

	onMount(async () => {
		const module = await import("browser-image-resizer");
		compress = module.readAndCompressImage;

		modelId = findCurrentModel(models, assistant ? assistant.modelId : $settings.activeModel).id;
	});

	let inputMessage1 = $state(assistant?.exampleInputs[0] ?? "");
	let inputMessage2 = $state(assistant?.exampleInputs[1] ?? "");
	let inputMessage3 = $state(assistant?.exampleInputs[2] ?? "");
	let inputMessage4 = $state(assistant?.exampleInputs[3] ?? "");

	function resetErrors() {
		if (form) {
			form.errors = [];
			form.error = false;
		}
	}

	function onFilesChange(e: Event) {
		const inputEl = e.target as HTMLInputElement;
		if (inputEl.files?.length && inputEl.files[0].size > 0) {
			if (!inputEl.files[0].type.includes("image")) {
				inputEl.files = null;
				files = null;

				form = { error: true, errors: [{ field: "avatar", message: "Only images are allowed" }] };
				return;
			}
			files = inputEl.files;
			resetErrors();
			deleteExistingAvatar = false;
		}
	}

	function getError(field: string, returnForm: ActionData) {
		return returnForm?.errors.find((error) => error.field === field)?.message ?? "";
	}

	let deleteExistingAvatar = $state(false);

	let loading = $state(false);

	let ragMode: false | "links" | "domains" | "all" = $state(
		assistant?.rag?.allowAllDomains
			? "all"
			: (assistant?.rag?.allowedLinks?.length ?? 0 > 0)
				? "links"
				: (assistant?.rag?.allowedDomains?.length ?? 0) > 0
					? "domains"
					: false
	);

	let tools = $state(assistant?.tools ?? []);
	const regex = /{{\s?(get|post|url|today)(=.*?)?\s?}}/g;

	let templateVariables = $derived([...systemPrompt.matchAll(regex)]);
	let selectedModel = $derived(models.find((m) => m.id === modelId));
</script>

<form
	method="POST"
	class="relative flex h-full flex-col overflow-y-auto p-4 md:p-8"
	enctype="multipart/form-data"
	use:enhance={async ({ formData }) => {
		loading = true;
		if (files?.[0] && files[0].size > 0 && compress) {
			await compress(files[0], {
				maxWidth: 500,
				maxHeight: 500,
				quality: 1,
			}).then((resizedImage) => {
				formData.set("avatar", resizedImage);
			});
		}

		if (deleteExistingAvatar === true) {
			if (assistant?.avatar) {
				// if there is an avatar we explicitly removei t
				formData.set("avatar", "null");
			} else {
				// else we just remove it from the input
				formData.delete("avatar");
			}
		} else {
			if (files === null) {
				formData.delete("avatar");
			}
		}

		formData.delete("ragMode");

		if (ragMode === false || !$page.data.enableAssistantsRAG) {
			formData.set("ragAllowAll", "false");
			formData.set("ragLinkList", "");
			formData.set("ragDomainList", "");
		} else if (ragMode === "all") {
			formData.set("ragAllowAll", "true");
			formData.set("ragLinkList", "");
			formData.set("ragDomainList", "");
		} else if (ragMode === "links") {
			formData.set("ragAllowAll", "false");
			formData.set("ragDomainList", "");
		} else if (ragMode === "domains") {
			formData.set("ragAllowAll", "false");
			formData.set("ragLinkList", "");
		}

		formData.set("tools", tools.join(","));

		return async ({ result }) => {
			loading = false;
			await applyAction(result);
		};
	}}
>
	{#if assistant}
		<h2 class="text-xl font-semibold">
			{$i18n.t('assistant.edit_title', { name: assistant?.name ?? "assistant" })}
		</h2>
		<p class="mb-6 text-sm text-gray-500">
			{$i18n.t('assistant.edit_description')}
		</p>
	{:else}
		<h2 class="text-xl font-semibold">{$i18n.t('assistant.create_title')}</h2>
		<p class="mb-6 text-sm text-gray-500">
			{$i18n.t('assistant.create_description')} <span
				class="rounded-full border px-2 py-0.5 leading-none">{$i18n.t('assistant.public_badge')}</span
			>
		</p>
	{/if}

	<div class="grid h-full w-full flex-1 grid-cols-2 gap-6 text-sm max-sm:grid-cols-1">
		<div class="col-span-1 flex flex-col gap-4">
			<div>
				<div class="mb-1 block pb-2 text-sm font-semibold">{$i18n.t('assistant.avatar')}</div>
				<input
					type="file"
					accept="image/*"
					name="avatar"
					id="avatar"
					class="hidden"
					onchange={onFilesChange}
				/>

				{#if (files && files[0]) || (assistant?.avatar && !deleteExistingAvatar)}
					<div class="group relative mx-auto h-12 w-12">
						{#if files && files[0]}
							<img
								src={URL.createObjectURL(files[0])}
								alt={$i18n.t('assistant.avatar')}
								class="crop mx-auto h-12 w-12 cursor-pointer rounded-full object-cover"
							/>
						{:else if assistant?.avatar}
							<img
								src="{base}/settings/assistants/{assistant._id}/avatar.jpg?hash={assistant.avatar}"
								alt={$i18n.t('assistant.avatar')}
								class="crop mx-auto h-12 w-12 cursor-pointer rounded-full object-cover"
							/>
						{/if}

						<label
							for="avatar"
							class="invisible absolute bottom-0 h-12 w-12 rounded-full bg-black bg-opacity-50 p-1 group-hover:visible hover:visible"
						>
							<CarbonPen class="mx-auto my-auto h-full cursor-pointer text-center text-white" />
						</label>
					</div>
					<div class="mx-auto w-max pt-1">
						<button
							type="button"
							onclick={(e) => {
								e.preventDefault();
								e.stopPropagation();
								files = null;
								deleteExistingAvatar = true;
							}}
							class="mx-auto w-max text-center text-xs text-gray-600 hover:underline"
						>
							{$i18n.t('button.delete')}
						</button>
					</div>
				{:else}
					<div class="mb-1 flex w-max flex-row gap-4">
						<label
							for="avatar"
							class="btn flex h-8 rounded-lg border bg-white px-3 py-1 text-gray-500 shadow-sm transition-all hover:bg-gray-100"
						>
							<CarbonUpload class="mr-2 text-xs " /> {$i18n.t('button.upload')}
						</label>
					</div>
				{/if}
				<p class="text-xs text-red-500">{getError("avatar", form)}</p>
			</div>

			<label>
				<div class="mb-1 font-semibold">{$i18n.t('assistant.name')}</div>
				<input
					name="name"
					class="w-full rounded-lg border-2 border-gray-200 bg-gray-100 p-2"
					placeholder={$i18n.t('assistant.name_placeholder')}
					value={assistant?.name ?? ""}
				/>
				<p class="text-xs text-red-500">{getError("name", form)}</p>
			</label>

			<label>
				<div class="mb-1 font-semibold">{$i18n.t('assistant.description')}</div>
				<textarea
					name="description"
					class="h-15 w-full rounded-lg border-2 border-gray-200 bg-gray-100 p-2"
					placeholder={$i18n.t('assistant.description_placeholder')}
					value={assistant?.description ?? ""}
				></textarea>
				<p class="text-xs text-red-500">{getError("description", form)}</p>
			</label>

			<label>
				<div class="mb-1 font-semibold">{$i18n.t('assistant.model')}</div>
				<div class="flex gap-2">
					<select
						name="modelId"
						class="w-full rounded-lg border-2 border-gray-200 bg-gray-100 p-2"
						bind:value={modelId}
					>
						{#each models.filter((model) => !model.unlisted) as model}
							<option value={model.id}>{model.displayName}</option>
						{/each}
					</select>
					<p class="text-xs text-red-500">{getError("modelId", form)}</p>
					<button
						type="button"
						class="flex aspect-square items-center gap-2 whitespace-nowrap rounded-lg border px-3 {showModelSettings
							? 'border-blue-500/20 bg-blue-50 text-blue-600'
							: ''}"
						onclick={() => (showModelSettings = !showModelSettings)}
						><CarbonSettingsAdjust class="text-xs" /></button
					>
				</div>
				<div
					class="mt-2 rounded-lg border border-blue-500/20 bg-blue-500/5 px-2 py-0.5"
					class:hidden={!showModelSettings}
				>
					<p class="text-xs text-red-500">{getError("inputMessage1", form)}</p>
					<div class="my-2 grid grid-cols-1 gap-2.5 sm:grid-cols-2 sm:grid-rows-2">
						<label for="temperature" class="flex justify-between">
							<span class="m-1 ml-0 flex items-center gap-1.5 whitespace-nowrap text-sm">
								Temperature

								<HoverTooltip
									label="Temperature: Controls creativity, higher values allow more variety."
								>
									<CarbonHelpFilled
										class="inline text-xxs text-gray-500 group-hover/tooltip:text-blue-600"
									/>
								</HoverTooltip>
							</span>
							<input
								type="number"
								name="temperature"
								min="0.1"
								max="2"
								step="0.1"
								class="w-20 rounded-lg border-2 border-gray-200 bg-gray-100 px-2 py-1"
								placeholder={selectedModel?.parameters?.temperature?.toString() ?? "1"}
								value={assistant?.generateSettings?.temperature ?? ""}
							/>
						</label>
						<label for="top_p" class="flex justify-between">
							<span class="m-1 ml-0 flex items-center gap-1.5 whitespace-nowrap text-sm">
								Top P
								<HoverTooltip
									label="Top P: Sets word choice boundaries, lower values tighten focus."
								>
									<CarbonHelpFilled
										class="inline text-xxs text-gray-500 group-hover/tooltip:text-blue-600"
									/>
								</HoverTooltip>
							</span>

							<input
								type="number"
								name="top_p"
								class="w-20 rounded-lg border-2 border-gray-200 bg-gray-100 px-2 py-1"
								min="0.05"
								max="1"
								step="0.05"
								placeholder={selectedModel?.parameters?.top_p?.toString() ?? "1"}
								value={assistant?.generateSettings?.top_p ?? ""}
							/>
						</label>
						<label for="repetition_penalty" class="flex justify-between">
							<span class="m-1 ml-0 flex items-center gap-1.5 whitespace-nowrap text-sm">
								Repetition penalty
								<HoverTooltip
									label="Repetition penalty: Prevents reuse, higher values decrease repetition."
								>
									<CarbonHelpFilled
										class="inline text-xxs text-gray-500 group-hover/tooltip:text-blue-600"
									/>
								</HoverTooltip>
							</span>
							<input
								type="number"
								name="repetition_penalty"
								min="0.1"
								max="2"
								step="0.05"
								class="w-20 rounded-lg border-2 border-gray-200 bg-gray-100 px-2 py-1"
								placeholder={selectedModel?.parameters?.repetition_penalty?.toString() ?? "1.0"}
								value={assistant?.generateSettings?.repetition_penalty ?? ""}
							/>
						</label>
						<label for="top_k" class="flex justify-between">
							<span class="m-1 ml-0 flex items-center gap-1.5 whitespace-nowrap text-sm">
								Top K <HoverTooltip
									label="Top K: Restricts word options, lower values for predictability."
								>
									<CarbonHelpFilled
										class="inline text-xxs text-gray-500 group-hover/tooltip:text-blue-600"
									/>
								</HoverTooltip>
							</span>
							<input
								type="number"
								name="top_k"
								min="5"
								max="100"
								step="5"
								class="w-20 rounded-lg border-2 border-gray-200 bg-gray-100 px-2 py-1"
								placeholder={selectedModel?.parameters?.top_k?.toString() ?? "50"}
								value={assistant?.generateSettings?.top_k ?? ""}
							/>
						</label>
					</div>
				</div>
			</label>

			<label>
				<div class="mb-1 font-semibold">{$i18n.t('assistant.start_messages')}</div>
				<div class="grid gap-1.5 text-sm md:grid-cols-2">
					<input
						name="exampleInput1"
						placeholder={$i18n.t('assistant.start_message_placeholder', { number: 1 })}
						bind:value={inputMessage1}
						class="w-full rounded-lg border-2 border-gray-200 bg-gray-100 p-2"
					/>
					<input
						name="exampleInput2"
						placeholder={$i18n.t('assistant.start_message_placeholder', { number: 2 })}
						bind:value={inputMessage2}
						class="w-full rounded-lg border-2 border-gray-200 bg-gray-100 p-2"
					/>

					<input
						name="exampleInput3"
						placeholder={$i18n.t('assistant.start_message_placeholder', { number: 3 })}
						bind:value={inputMessage3}
						class="w-full rounded-lg border-2 border-gray-200 bg-gray-100 p-2"
					/>
					<input
						name="exampleInput4"
						placeholder={$i18n.t('assistant.start_message_placeholder', { number: 4 })}
						bind:value={inputMessage4}
						class="w-full rounded-lg border-2 border-gray-200 bg-gray-100 p-2"
					/>
				</div>
				<p class="text-xs text-red-500">{getError("inputMessage1", form)}</p>
			</label>
			{#if selectedModel?.tools}
				<div>
					<span class="text-smd font-semibold"
						>{$i18n.t('assistant.tools_section')}
						<CarbonTools class="inline text-xs text-purple-600" />
						<span class="ml-1 rounded bg-gray-100 px-1 py-0.5 text-xxs font-normal text-gray-600"
							>{$i18n.t('assistant.tools_experimental')}</span
						>
					</span>
					<p class="text-xs text-gray-500">
						{$i18n.t('assistant.tools_description')}
					</p>
				</div>
				<AssistantToolPicker bind:toolIds={tools} />
			{/if}
			{#if $page.data.enableAssistantsRAG}
				<div class="flex flex-col flex-nowrap pb-4">
					<span class="mt-2 text-smd font-semibold"
						>{$i18n.t('assistant.internet_access')}
						<IconInternet classNames="inline text-sm text-blue-600" />

						{#if isHuggingChat}
							<a
								href="https://huggingface.co/spaces/huggingchat/chat-ui/discussions/385"
								target="_blank"
								class="ml-0.5 rounded bg-gray-100 px-1 py-0.5 text-xxs font-normal text-gray-700 underline decoration-gray-400"
								>{$i18n.t('assistant.give_feedback')}</a
							>
						{/if}
					</span>

					<label class="mt-1">
						<input
							checked={!ragMode}
							onchange={() => (ragMode = false)}
							type="radio"
							name="ragMode"
							value={false}
						/>
						<span class="my-2 text-sm" class:font-semibold={!ragMode}> {$i18n.t('assistant.internet_default')} </span>
						{#if !ragMode}
							<span class="block text-xs text-gray-500">
								{$i18n.t('assistant.internet_default_description')}
							</span>
						{/if}
					</label>

					<label class="mt-1">
						<input
							checked={ragMode === "all"}
							onchange={() => (ragMode = "all")}
							type="radio"
							name="ragMode"
							value={"all"}
						/>
						<span class="my-2 text-sm" class:font-semibold={ragMode === "all"}> {$i18n.t('assistant.web_search')} </span>
						{#if ragMode === "all"}
							<span class="block text-xs text-gray-500">
								{$i18n.t('assistant.web_search_description')}
							</span>
						{/if}
					</label>

					<label class="mt-1">
						<input
							checked={ragMode === "domains"}
							onchange={() => (ragMode = "domains")}
							type="radio"
							name="ragMode"
							value={false}
						/>
						<span class="my-2 text-sm" class:font-semibold={ragMode === "domains"}>
							{$i18n.t('assistant.domains_search')}
						</span>
					</label>
					{#if ragMode === "domains"}
						<span class="mb-2 text-xs text-gray-500">
							{$i18n.t('assistant.domains_description')}
						</span>

						<input
							name="ragDomainList"
							class="w-full rounded-lg border-2 border-gray-200 bg-gray-100 p-2"
							placeholder={$i18n.t('assistant.domains_placeholder')}
							value={assistant?.rag?.allowedDomains?.join(",") ?? ""}
						/>
						<p class="text-xs text-red-500">{getError("ragDomainList", form)}</p>
					{/if}

					<label class="mt-1">
						<input
							checked={ragMode === "links"}
							onchange={() => (ragMode = "links")}
							type="radio"
							name="ragMode"
							value={false}
						/>
						<span class="my-2 text-sm" class:font-semibold={ragMode === "links"}>
							{$i18n.t('assistant.specific_links')}
						</span>
					</label>
					{#if ragMode === "links"}
						<span class="mb-2 text-xs text-gray-500">
							{$i18n.t('assistant.specific_links_description')}
						</span>
						<input
							name="ragLinkList"
							class="w-full rounded-lg border-2 border-gray-200 bg-gray-100 p-2"
							placeholder={$i18n.t('assistant.specific_links_placeholder')}
							value={assistant?.rag?.allowedLinks.join(",") ?? ""}
						/>
						<p class="text-xs text-red-500">{getError("ragLinkList", form)}</p>
					{/if}
				</div>
			{/if}
		</div>

		<div class="relative col-span-1 flex h-full flex-col">
			<div class="mb-1 flex justify-between text-sm">
				<span class="block font-semibold"> {$i18n.t('assistant.instructions')} </span>
				{#if dynamicPrompt && templateVariables.length}
					<div class="relative">
						<button
							type="button"
							class="peer rounded bg-blue-500/20 px-1 text-xs text-blue-600 focus:bg-blue-500/30 focus:text-blue-800 sm:text-sm"
						>
							{templateVariables.length} {$i18n.t(templateVariables.length > 1 ? 'assistant.template_variables_plural' : 'assistant.template_variables')}
						</button>
						<div
							class="invisible absolute right-0 top-6 z-10 rounded-lg border bg-white p-2 text-xs shadow-lg peer-focus:visible hover:visible sm:w-96"
						>
							{$i18n.t('assistant.template_variables_description')}
							{#each templateVariables as match}
								<div>
									<a
										href={match[1].toLowerCase() === "get" ? match[2] : "#"}
										target={match[1].toLowerCase() === "get" ? "_blank" : ""}
										class="text-gray-500 underline decoration-gray-300"
									>
										{match[1].toUpperCase()}: {match[2]}
									</a>
								</div>
							{/each}
						</div>
					</div>
				{/if}
			</div>
			<label class="pb-2 text-sm has-[:checked]:font-semibold">
				<input type="checkbox" name="dynamicPrompt" bind:checked={dynamicPrompt} />
				{$i18n.t('assistant.dynamic_prompt')}
				<p class="mb-2 text-xs font-normal text-gray-500">
					{$i18n.t('assistant.dynamic_prompt_description')}
				</p>
			</label>

			<div class="relative mb-20 flex h-full flex-col gap-2">
				<textarea
					name="preprompt"
					class="min-h-[8lh] flex-1 rounded-lg border-2 border-gray-200 bg-gray-100 p-2 text-sm"
					placeholder={$i18n.t('assistant.instructions_placeholder')}
					bind:value={systemPrompt}
				></textarea>
				{#if modelId}
					{@const model = models.find((_model) => _model.id === modelId)}
					{#if model?.tokenizer && systemPrompt}
						<TokensCounter
							classNames="absolute bottom-4 right-4"
							prompt={systemPrompt}
							modelTokenizer={model.tokenizer}
							truncate={model?.parameters?.truncate}
						/>
					{/if}
				{/if}

				<p class="text-xs text-red-500">{getError("preprompt", form)}</p>
			</div>
			<div class="absolute bottom-6 flex w-full justify-end gap-2 md:right-0 md:w-fit">
				<a
					href={assistant ? `${base}/settings/assistants/${assistant?._id}` : `${base}/settings`}
					class="flex items-center justify-center rounded-full bg-gray-200 px-5 py-2 font-semibold text-gray-600"
				>
					{$i18n.t('button.cancel')}
				</a>
				<button
					type="submit"
					disabled={loading}
					aria-disabled={loading}
					class="flex items-center justify-center rounded-full bg-black px-8 py-2 font-semibold"
					class:bg-gray-200={loading}
					class:text-gray-600={loading}
					class:text-white={!loading}
				>
					{assistant ? $i18n.t('button.save') : $i18n.t('button.create')}
				</button>
			</div>
		</div>
	</div>
</form>
